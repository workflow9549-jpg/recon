#!/usr/bin/env bash

# اسم ملف النتائج
OUTPUT_FILE="found_secrets.txt"
> "$OUTPUT_FILE"

echo "[*] Starting to mine secrets from JS files..."

# القائمة دي فيها Regex لأغلب الحاجات اللي في الصورة وزيادة
# Stripe, Google, Cloudflare, Firebase, AWS, etc.

declare -A patterns=(
    ["Cloudflare_ID_Secret"]="([0-9a-f]{32}-[0-9a-f]{32})"
    ["Google_OAuth_Client_ID"]="([0-9a-fA-Z+_.-]{24}\.apps\.googleusercontent\.com)"
    ["Stripe_Publishable_Key"]="(pk_live_[0-9a-zA-Z]{24})"
    ["Stripe_Secret_Key"]="(sk_live_[0-9a-zA-Z]{24})"
    ["Firebase_API_Key"]="(AIza[0-9A-Za-z\\-_]{35})"
    ["Generic_API_Key"]="((api|API)_?(key|KEY)['\"\s]*[:=]['\"\s]*[0-9a-zA-Z]{16,45})"
    ["Authorization_Basic"]="(Authorization:\sBasic\s[a-zA-Z0-9+/=]+)"
    ["Authorization_Bearer"]="(Authorization:\sBearer\s[a-zA-Z0-9._-]+)"
    ["AWS_Access_Key"]="(AKIA[0-9A-Z]{16})"
    ["Slack_Token"]="(xox[baprs]-[0-9a-zA-Z]{10,48})"
    ["Mapbox_Token"]="(pk\.[a-zA-Z0-9]{60}\.[a-zA-Z0-9]{20})"
    ["Mailgun_API_Key"]="(key-[0-9a-zA-Z]{32})"
    ["GitHub_Token"]="((ghp|gho|ghu|ghs|ghr)_[a-zA-Z0-9]{36})"
    ["Vite_App_Credentials"]="(VITE_APP_[A-Z0-9_]+['\"\s]*[:=]['\"\s]*[^ \n]+)"
)

# اللوب اللي بيمشي على كل ملف JS ويطبق الـ Regex
for name in "${!patterns[@]}"; do
    echo "[+] Searching for $name..."
    # بنستخدم grep -rEi (R: recursive, E: regex, i: ignore case)
    grep -rEiho "${patterns[$name]}" . >> "$OUTPUT_FILE" || true
done

# تنظيف النتائج وإزالة التكرار
sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

echo "[!] Done! Found secrets saved in: $OUTPUT_FILE"
echo "[*] Quick Preview of findings:"
head -n 20 "$OUTPUT_FILE"
