import {FieldValue} from "firebase-admin/firestore";
import {logger} from "firebase-functions/v2";
import {db, messaging} from "./firebase-admin";
import {NotificationChannelId, NotificationType} from "./enums";

function isNotificationType(value: string): value is NotificationType {
  return Object.values(NotificationType).includes(value as NotificationType);
}

function getNotificationChannelId(type: string): NotificationChannelId {
  if (!isNotificationType(type)) {
    logger.warn(`Unknown notification type "${type}", defaulting to General channel`);
    return NotificationChannelId.General;
  }

  if (type === NotificationType.Message) return NotificationChannelId.Messages;
  if (type === NotificationType.RideRequest || type === NotificationType.RideUpdate) {
    return NotificationChannelId.Rides;
  }
  return NotificationChannelId.General;
}

export async function removeStaleToken(userId: string): Promise<void> {
  logger.info(`Removing stale FCM token for user ${userId}`);
  await db
    .collection("users")
    .doc(userId)
    .update({ fcmToken: FieldValue.delete() });
}

export async function sendPushToUser(
  userId: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  try {
    const userDoc = await db.collection("users").doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken as string | undefined;

    if (!fcmToken) {
      logger.info(`No FCM token for user ${userId}, skipping push`);
      return;
    }

    await messaging.send({
      token: fcmToken,
      notification: { title, body },
      data,
      android: {
        priority: "high",
        notification: {
          channelId: getNotificationChannelId(data.type),
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    });

    logger.info(`Push sent to ${userId}: "${title}"`);
  } catch (error: unknown) {
    const e = error as { code?: string };
    if (
      e.code === "messaging/registration-token-not-registered" ||
      e.code === "messaging/invalid-registration-token" ||
      e.code === "messaging/invalid-argument"
    ) {
      await removeStaleToken(userId);
    } else {
      logger.error(`Failed to send push to ${userId}:`, error);
    }
  }
}

export async function sendPushToMultipleUsers(
  userIds: string[],
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  if (userIds.length === 0) return;

  const userRefs = userIds.map((id) => db.collection("users").doc(id));
  const userDocs = await db.getAll(...userRefs);

  const tokenToUserId: Record<string, string> = {};
  const tokens: string[] = [];

  userDocs.forEach((doc, index) => {
    const token = doc.data()?.fcmToken as string | undefined;
    if (token) {
      tokens.push(token);
      tokenToUserId[token] = userIds[index];
    } else {
      logger.info(`No FCM token for user ${userIds[index]}, skipping`);
    }
  });

  if (tokens.length === 0) return;

  const response = await messaging.sendEachForMulticast({
    tokens,
    notification: { title, body },
    data,
    android: {
      priority: "high",
      notification: {
        channelId: getNotificationChannelId(data.type),
        sound: "default",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
        },
      },
    },
  });

  if (response.failureCount > 0) {
    const cleanupPromises: Promise<void>[] = [];
    response.responses.forEach((resp, index) => {
      if (!resp.success && resp.error) {
        const code = resp.error.code;
        const staleToken = tokens[index];
        const userId = tokenToUserId[staleToken];
        if (
          code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token" ||
          code === "messaging/invalid-argument"
        ) {
          cleanupPromises.push(removeStaleToken(userId));
        } else {
          logger.error(`FCM send failed for user ${userId}:`, resp.error);
        }
      }
    });
    await Promise.all(cleanupPromises);
  }

  logger.info(
    `Multicast sent: ${response.successCount} success, ${response.failureCount} failure out of ${tokens.length}`,
  );
}
