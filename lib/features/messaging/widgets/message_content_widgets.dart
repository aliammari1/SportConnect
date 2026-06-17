import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Dispatches to the correct content widget based on [MessageType].
class MessageContent extends StatelessWidget {
  const MessageContent({
    required this.message,
    required this.isMe,
    required this.onLocationTap,
    super.key,
  });

  final MessageModel message;
  final bool isMe;
  final void Function(double lat, double lng, String label) onLocationTap;

  @override
  Widget build(BuildContext context) {
    return switch (message.type) {
      MessageType.image when message.mediaUrl != null => RepaintBoundary(
        child: ImageMessageContent(mediaUrl: message.mediaUrl!),
      ),
      MessageType.location
          when message.latitude != null && message.longitude != null =>
        RepaintBoundary(
          child: LocationMessageContent(
            message: message,
            isMe: isMe,
            onTap: () => onLocationTap(
              message.latitude!,
              message.longitude!,
              message.content,
            ),
          ),
        ),
      _ => TextMessageContent(message: message, isMe: isMe),
    };
  }
}

/// Network image with loading shimmer.
class ImageMessageContent extends StatelessWidget {
  const ImageMessageContent({required this.mediaUrl, super.key});

  final String mediaUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: CachedNetworkImage(
        imageUrl: mediaUrl,
        width: 200.w,
        fit: BoxFit.cover,
        placeholder: (ctx, url) => Container(
          width: 200.w,
          height: 150.h,
          color: AppColors.surfaceVariant,
          child: const Center(child: CircularProgressIndicator.adaptive()),
        ),
        errorWidget: (ctx, url, err) => Container(
          width: 200.w,
          height: 150.h,
          color: AppColors.surfaceVariant,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

/// Static map preview + address label. Tappable to open in maps app.
class LocationMessageContent extends StatelessWidget {
  const LocationMessageContent({
    required this.message,
    required this.isMe,
    required this.onTap,
    super.key,
  });

  final MessageModel message;
  final bool isMe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mapUrl =
        'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=${message.latitude},${message.longitude}'
        '&zoom=15&size=200x120&maptype=osmarenderer'
        '&markers=${message.latitude},${message.longitude},red-pushpin';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: mapUrl,
                  width: 200.w,
                  height: 120.h,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 200.w,
                    height: 120.h,
                    color: AppColors.surfaceVariant,
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 200.w,
                    height: 120.h,
                    color: AppColors.surfaceVariant,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_rounded,
                          size: 32.sp,
                          color: isMe
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          AppLocalizations.of(context).tapToOpenMap,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isMe
                                ? Colors.white70
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  progressIndicatorBuilder: (_, _, progress) => Container(
                    width: 200.w,
                    height: 120.h,
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          AppLocalizations.of(context).open,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16.sp,
                color: isMe ? Colors.white70 : const Color(0xFF4CAF50),
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  message.content.replaceFirst('📍 ', ''),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isMe ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Plain text or deleted-message placeholder.
class TextMessageContent extends StatelessWidget {
  const TextMessageContent({
    required this.message,
    required this.isMe,
    super.key,
  });

  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Text(
      message.isDeleted
          ? AppLocalizations.of(context).thisMessageWasDeleted
          : message.content,
      style: TextStyle(
        fontSize: 14.sp,
        color: isMe ? Colors.white : AppColors.textPrimary,
        fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
        height: 1.4,
      ),
    );
  }
}

/// Timestamp + edited flag + read-receipt icon row.
class MessageMetaRow extends StatelessWidget {
  const MessageMetaRow({
    required this.message,
    required this.isMe,
    required this.formattedTime,
    super.key,
  });

  final MessageModel message;
  final bool isMe;
  final String formattedTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited)
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Text(
              AppLocalizations.of(context).edited,
              style: TextStyle(
                fontSize: 12.sp,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppColors.textTertiary,
              ),
            ),
          ),
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: 11.sp,
            color: isMe
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.textTertiary,
          ),
        ),
        if (isMe) ...[
          SizedBox(width: 4.w),
          Icon(
            // delivered and read both show double-tick; color distinguishes them.
            message.status == MessageStatus.read ||
                    message.status == MessageStatus.delivered
                ? Icons.done_all_rounded
                : Icons.done_rounded,
            size: 14.sp,
            color: message.status == MessageStatus.read
                ? Colors.lightBlueAccent
                : Colors.white.withValues(alpha: 0.7),
          ),
        ],
      ],
    );
  }
}

/// Quoted-message strip shown above a bubble when replying.
class ReplyIndicator extends StatelessWidget {
  const ReplyIndicator({required this.content, super.key});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.r),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      child: Text(
        content,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
