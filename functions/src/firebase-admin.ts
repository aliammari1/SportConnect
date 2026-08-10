import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { getStorage } from "firebase-admin/storage";
import { setGlobalOptions } from "firebase-functions/v2";

initializeApp();

setGlobalOptions({ region: "us-central1", cpu: 0.5})

export const db = getFirestore();
export const messaging = getMessaging();
export const storage = getStorage();
