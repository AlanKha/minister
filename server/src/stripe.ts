import Stripe from 'stripe';
import { stripeSecretKey } from './config.js';

export const stripe = new Stripe(stripeSecretKey, {
  apiVersion: '2023-10-16' as Stripe.LatestApiVersion,
});
