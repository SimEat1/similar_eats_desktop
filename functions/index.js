/* eslint-disable */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const vision = require("@google-cloud/vision");

admin.initializeApp();
const db = admin.firestore();
const client = new vision.ImageAnnotatorClient();

exports.onReceiptImage = functions.storage.object().onFinalize(async (obj) => {
  const filePath = obj.name || "";
  const m = filePath.match(/^users\/([^/]+)\/receipts\/([^/.]+)\.jpg$/i);
  if (!m) return;
  const uid = m[1], rid = m[2];

  try {
    const [result] = await client.textDetection(`gs://${obj.bucket}/${filePath}`);
    const text = result.fullTextAnnotation?.text || "";
    await db.doc(`users/${uid}/receipts/${rid}`).set({
      ocrText: text,
      merchant: "",
      totalCents: 0,
      purchasedAt: new Date().toISOString(),
      imagePath: filePath,
      source: "cloud_vision",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    console.log(`OCR stored for ${uid}/${rid} (${text.length} chars)`);
  } catch (e) {
    console.error("OCR error:", e.message || e);
    await db.doc(`users/${uid}/receipts/${rid}`).set({
      ocrError: String(e),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  }
});
