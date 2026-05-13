import re

with open('lib/core/constants/app_text_constants.dart', 'r') as f:
    lines = f.readlines()

seen = set()
out_lines = []

for line in lines:
    m = re.match(r'^\s*static const String (\w+)\s*=', line)
    if m:
        key = m.group(1)
        if key in seen:
            continue
        seen.add(key)
    out_lines.append(line)

# Now, add the missing ones that were reported by the compiler but still missing
missing_keys = [
    'dutyType', 'add', 'vehicleNumber', 'expiryDate', 'viewRcInsurance', 'access'
]

# We should insert these before the last '}'
# First, remove trailing empty lines and the closing brace
while out_lines[-1].strip() == '' or out_lines[-1].strip() == '}':
    out_lines.pop()

for key in missing_keys:
    if key not in seen:
        snake_case = re.sub(r'(?<!^)(?=[A-Z])', '_', key).lower()
        out_lines.append(f"  static const String {key} = '{snake_case}';\n")
        seen.add(key)

out_lines.append('}\n')

with open('lib/core/constants/app_text_constants.dart', 'w') as f:
    f.writelines(out_lines)

