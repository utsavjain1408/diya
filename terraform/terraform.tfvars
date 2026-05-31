bucket_name = "diya-terraform-bucket"

# Populated during DNS step 3, after the dev/staging child zones are created.
# Copy the "child_name_servers" values from each environment's tf-deploy job
# summary here. Only the production run consumes this (to create the delegation
# NS records in the parent diya.utsavjain.com zone).
#
# subdomain_delegations = {
#   "dev.diya.utsavjain.com" = [
#     "ns-xxxx.awsdns-xx.org",
#     "ns-xxxx.awsdns-xx.com",
#     "ns-xxxx.awsdns-xx.net",
#     "ns-xxxx.awsdns-xx.co.uk",
#   ]
#   "staging.diya.utsavjain.com" = [
#     "ns-xxxx.awsdns-xx.org",
#     "ns-xxxx.awsdns-xx.com",
#     "ns-xxxx.awsdns-xx.net",
#     "ns-xxxx.awsdns-xx.co.uk",
#   ]
# }
