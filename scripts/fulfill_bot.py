#!/usr/bin/env python3
"""ZQM PQC Readiness Toolkit fulfillment bot."""
import os, re, json, secrets, smtplib
from email.message import EmailMessage

issue_body = os.environ.get('ISSUE_BODY', '')
issue_url = os.environ.get('ISSUE_URL', '')
release_url = os.environ.get('RELEASE_URL', 'https://github.com/ZQM Computing/pqc-readiness-toolkit/releases/latest/download/zqm_pqc_readiness_package.zip')
expected_hash = os.environ.get('EXPECTED_HASH', '')

smtp_host = os.environ.get('SMTP_HOST', 'smtp.gmail.com')
smtp_port = int(os.environ.get('SMTP_PORT', '587'))
smtp_user = os.environ.get('SMTP_USER')
smtp_pass = os.environ.get('SMTP_PASS')
sender = os.environ.get('EMAIL_FROM', smtp_user)

if not smtp_user or not smtp_pass:
 raise SystemExit('SMTP_USER/SMTP_PASS not set')

LICENSE_PFX = 'ZQM-LIC-2026-'
TICKET_PFX = 'ZQM-TKT-2026-'

TIERS = {
 'PQC-ASSESS': '$350/endpoint',
 'PQC-PILOT': '$800/endpoint',
 'PQC-RETAINER': '$500-$2000/mo',
}
ADDONS = {
 'ZQM-PQC-ADD-REMEDIATION': 'PQC migration remediation runbook',
 'ZQM-PQC-ADD-VENDOR': 'Vendor PQ-readiness questionnaire',
}

def first(pattern, text, flags=0):
 m = re.search(pattern, text, flags)
 return m.group(1).strip() if m else None

sku = first(r'PQC-(?:ASSESS|PILOT|RETAINER)', issue_body)
if not sku:
 raise SystemExit('No valid PQC SKU found in issue body.')

txid = first(r'(?i)txid[:\\s]+([A-Za-z0-9]{64})', issue_body) or first(r'\\b([A-Za-z0-9]{64})\\b', issue_body)
if not txid:
 raise SystemExit('No txid found in issue body.')

buyer_email = first(r'(?i)email[:\\s]+([A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,})', issue_body)
if not buyer_email:
 buyer_email = smtp_user

addon_codes = re.findall(r'ZQM-PQC-ADD-[A-Z]+', issue_body)
addon_lines = []
for code in addon_codes:
 addon_lines.append(f' {code}: {ADDONS.get(code, "unknown")}')

license_id = f'{LICENSE_PFX}{secrets.token_hex(4).upper()}'
ticket_id = f'{TICKET_PFX}{secrets.token_hex(4).upper()}'
price = TIERS.get(sku, 'contact')

license_payload = {
 'ticket': ticket_id,
 'license_id': license_id,
 'sku': sku,
 'price': price,
 'txid': txid,
 'buyer_email': buyer_email,
 'addons': addon_codes,
 'release_url': release_url,
 'expected_sha256': expected_hash,
}

receipt = f"""Hello,

PQC Readiness Toolkit license confirmed.

Ticket: {ticket_id}
License ID: {license_id}
SKU: {sku}
Price: {price}
Payment txid: {txid}
Licensed contact: {buyer_email}

Download:
 {release_url}

Verify the release before extracting:
 (Get-FileHash zqm_pqc_readiness_package.zip -Algorithm SHA256).Hash

Expected SHA256: {expected_hash}

Support: zqmcomputing@gmail.com
Reference: {issue_url}

Do not share your license ID publicly. This email is your receipt.
"""

if addon_lines:
 receipt += '\nIncluded add-ons:\n' + '\n'.join(addon_lines) + '\n'

msg = EmailMessage()
msg['Subject'] = f'Your ZQM PQC Readiness Toolkit receipt — {license_id}'
msg['From'] = sender
msg['To'] = buyer_email
msg.set_content(receipt)

with smtplib.SMTP(smtp_host, smtp_port) as s:
 s.ehlo()
 s.starttls()
 s.login(smtp_user, smtp_pass)
 s.send_message(msg)

out = {
 'ticket': ticket_id,
 'license_id': license_id,
 'sku': sku,
 'txid': txid,
 'buyer_email': buyer_email,
 'addons': addon_codes,
}
print(json.dumps(out))
