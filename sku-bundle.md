# PQC Readiness Attestation — Deliverable Package
SKUID: ZQM-PQC-READINESS-001
Version: 1.0.0-draft
Baseline methodology: 11 standards mapped in `templates/standards_matrix.md`

## What the customer receives
- CMS-signed PQC Readiness Report + per-endpoint hash ledger
- Evidence pack: asymmetric-key inventory, TLS/cipher-suite state, BitLocker/smart-card exposure, code-signing cert lifecycle
- Migration playbook with prioritized workload list
- Vendor attestation template questionnaire + review matrix

## SKU Bundles
| Tier | SKU | Includes | Rate |
|---|---|---|---|
| Assessment | PQC-ASSESS | Discovery + report | $350/endpoint |
| Pilot | PQC-PILOT | Assessment + 1 staged profile (TLS or code-sign) | $800/endpoint |
| Subscription | PQC-RETAINER | Quarterly reassessment + roadmap updates | $500-$2000/mo |

## Release roots
- Deliverable root: `dist/`
- Payment flow: `PAYMENT_INSTRUCTIONS.md` + GitHub `purchase` label → fulfillment
