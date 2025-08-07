# Tenant Domains Finder

A simple Bash script to discover all domains associated with a specific Microsoft 365 tenant.

It acts as a successor to [check_mdi](https://github.com/expl0itabl3/check_mdi).

## Description

This tool helps identify all domain names belonging to a single Microsoft 365 tenant. It works in two steps:

1. It queries a public Microsoft endpoint (`login.microsoftonline.com`) with a given domain name to retrieve the unique Tenant ID.
2. It sends this Tenant ID to a backend API to find all other domains that have been publicly associated with that same tenant.

This can be useful for security professionals during the recon phase of a penetration test or for system administrators trying to map out their organization's digital footprint.

## Shoutout & Backend Notice

This tool is entirely dependent on the fantastic work done by *Micah Van Deusen* and the [public API](https://micahvandeusen.com/tools/tenant-domains/) he maintains.

- **Credit** - all credit for the original concept, the backend API and the web tool goes to Micah. You can read about his work on [his website](https://micahvandeusen.com/tools/tenant-domains/).
- **Backend API** - the API used is `tenant-api.micahvandeusen.com`.

> I kept the project's name so it is clear that Micah's work is the base for this.

**Important Usage Note**

The backend service is a public resource maintained by Micah. Please **do not abuse** it and be mindful, that sending a high volume of automated requests can overload the service, potentially making it unavailable for the community. Responsible use is appreciated to ensure the tool remains functional for everyone.

## Usage

```bash
# Display the help message
./tenant-domains.sh --help

# Find domains for a specific company and print to the screen
./tenant-domains.sh --domain example.com

# Find domains and save the results to a file
./tenant-domains.sh -d example.com -o results.txt

# Run in silent mode and pipe to another tool like httpx
./tenant-domains.sh -d example.com -s | httpx -title
```

## Disclaimer

This tool is intended for educational and authorized security testing purposes only. The user is responsible for ensuring they have proper authorization before using this tool on any domain. The author is not responsible for any misuse or damage caused by this tool. Do not use this tool for any malicious activities.