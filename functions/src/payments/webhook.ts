import { logger } from "firebase-functions";
import { onRequest } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { PAYU_SECRETS } from "./payu";
import { settleIntent } from "./settle";

const TXNID = /^z[A-Za-z0-9]{24}$/;

/**
 * PayU's server-to-server webhook (dashboard → Webhooks, payment success
 * / failure). Only the txnid is read from the POST: the outcome always
 * comes from PayU's verify_payment via settleIntent, so a forged call
 * can at most make us re-check a payment.
 */
export const payuWebhook = onRequest({ secrets: PAYU_SECRETS }, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method not allowed");
    return;
  }
  const body = (req.body ?? {}) as Record<string, unknown>;
  const txnid = String(body.txnid ?? "").trim();
  if (!TXNID.test(txnid) || !(await db.collection("paymentIntents").doc(txnid).get()).exists) {
    // Not ours (or another integration's): acknowledge so PayU stops.
    res.status(200).send("ignored");
    return;
  }

  try {
    const { state } = await settleIntent(txnid);
    logger.info("PayU webhook", { txnid, state });
    res.status(200).send("ok");
  } catch (error) {
    // PayU retries non-2xx; the reconciler is the backstop either way.
    logger.warn("PayU webhook settle failed", { txnid, error: String(error) });
    res.status(500).send("retry");
  }
});
