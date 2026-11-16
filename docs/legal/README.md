# Legal documents (drafts)

> **These are drafts written for a lawyer to review. They are not legal advice.**
> They must be reviewed, and the `[PLACEHOLDERS]` filled in, before they are published.
> A chartered accountant should also confirm the tax clauses (GST TCS under §52 and income-tax TDS under §194-O).

| File | `legalDocs` type | Who accepts it | How |
|---|---|---|---|
| `customer-terms.md` | `customer_terms` | Customers (app) | Checkbox on login |
| `privacy-policy.md` | `privacy_policy` | Everyone | Checkbox, or together with the agreement |
| `refund-policy.md` | `refund_policy` | Customers | Checkbox on login |
| `rider-agreement.md` | `rider_agreement` | Delivery partners (rider app) | Drawn signature + phone OTP |
| `seller-agreement.md` | `seller_agreement` | Sellers (Zyppi Marketplace app/web) | Drawn signature + phone OTP |

## Placeholders to fill

| Placeholder | Meaning |
|---|---|
| `[COMPANY LEGAL NAME]` | The registered company that runs Zyppi |
| `[REGISTERED ADDRESS]` | Its registered office |
| `[CIN]` | Its Corporate Identity Number |
| `[GSTIN]` | Its GSTIN |
| `[GRIEVANCE OFFICER NAME]` | The grievance officer (Consumer Protection (E-Commerce) Rules 2020, IT Rules 2021, DPDP Act 2023) |
| `[SUPPORT EMAIL]` | Support email |
| `[GRIEVANCE EMAIL]` | Grievance email |
| `[SUPPORT PHONE]` | Support phone |
| `[EFFECTIVE DATE]` | Date the version takes effect |

Settings that are numbers in the text (hold days, acceptance time, payout minimum) must match `config/marketplace` and `config/riders`.

## Publishing

Each file starts with a front-matter block holding `type` and `title`. The script publishes the English text as the next version:

```sh
npm --prefix functions run publish-legal -- --project zippy-app-2024              # dry run
npm --prefix functions run publish-legal -- --project zippy-app-2024 --write      # publish changed docs
npm --prefix functions run publish-legal -- --project zippy-app-2024 --write --reaccept customer_terms
```

- **Placeholders:** the script refuses to publish while any `[PLACEHOLDER]` is left.
- **Unchanged files:** an unchanged file is skipped.
- **`--reaccept <type>`:** makes everyone accept that document again.
- **Rider agreement:** publishing it switches on the consent check for rider applications. Publish it only once the rider app collects the signature (R1).
- **Seller agreement:** the same applies to seller applications and the seller app (S1).
- **Translations:** Bengali, Hindi and Punjabi versions come after the English text has been reviewed. Publish them from the admin legal-documents editor, or by adding `<name>.bn.md` / `.hi.md` / `.pa.md` files.
