#!/usr/bin/env bash

# Based on an awesome project from Micah Van Deusen - https://micahvandeusen.com/tools/tenant-domains/

show_help() {
	echo "A script to query the tenant-domains service."
	echo ""
	echo "Usage: $0 [OPTIONS]"
	echo ""
	echo "Options:"
	echo "  -d, --domain <domain>        Search for a specific domain name (e.g., hackerone.com)"
	echo "  -o, --output <file>          File to save results. If not set, results are printed to stdout."
	echo "  -s, --silent                 Suppress banner and non-essential output."
	echo "  -h, --help                   Display this help message"
	echo ""
	echo "Examples:"
	echo "  $0 --domain hackerone.com"
	echo "  $0 --domain hackerone.com --output ./results.txt"
	echo "  $0 -d example.com -s | grep '.com'"
	echo "  $0 -d example.com -s | httpx"
}

domain_search() {
	local domain_req="$1"
	local silent_mode="$2"

	if [[ "$silent_mode" = false ]]; then
		# Print status messages to stderr to not interfere with stdout
		echo "[*] Searching for domain: $domain_req" >&2
	fi

	local msc_response
	msc_response=$(curl -fsL "https://login.microsoftonline.com/$domain_req/.well-known/openid-configuration" -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36")

	# If request fails or returns no data, return nothing.
	if [[ $? -ne 0 || -z "$msc_response" || "$msc_response" == "[]" ]]; then
		return
	fi

	local tenant_id
	tenant_id=$(echo "$msc_response" | jq -r '.token_endpoint' | cut -d'/' -f4)

	local response
	# A little obstacle for those who may want to abuse this to DoS
	sleep $(awk 'BEGIN{srand(); print 1 + rand() * 10}')
	response=$(curl -fsL "https://tenant-api.micahvandeusen.com/search?tenant_id=$tenant_id" -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36")

	local domains
	domains=$(echo "$response" | jq -r '.domains[]')

	echo "$domains"
}

DOMAIN_SEARCH=""
OUTPUT_FILE=""
SILENT_MODE=false

if [[ "$#" -eq 0 ]]; then
	show_help
	exit 0
fi

while [[ "$#" -gt 0 ]]; do
	case "$1" in
	-h | --help)
		show_help
		exit 0
		;;
	-s | --silent)
		SILENT_MODE=true
		;;
	-d | --domain)
		if [[ -n "$2" && ! "$2" =~ ^- ]]; then
			DOMAIN_SEARCH="$2"
			shift
		else
			echo "Error: Missing argument for $1" >&2
			exit 1
		fi
		;;
	-o | --output)
		if [[ -n "$2" && ! "$2" =~ ^- ]]; then
			OUTPUT_FILE="$2"
			shift
		else
			echo "Error: Missing argument for $1" >&2
			exit 1
		fi
		;;
	*)
		echo "Error: Unknown parameter passed: $1" >&2
		show_help
		exit 1
		;;
	esac
	shift
done

if [[ "$SILENT_MODE" = false ]]; then
	echo "${banner}" >&2
fi

if [[ -z "$DOMAIN_SEARCH" ]]; then
	show_help
	exit 0
fi

RESULTS=""
if [[ -n "$DOMAIN_SEARCH" ]]; then
	RESULTS=$(domain_search "$DOMAIN_SEARCH" "$SILENT_MODE")
fi

if [[ -z "$RESULTS" ]]; then
	if [[ "$SILENT_MODE" = false ]]; then
		echo "[-] No results found." >&2
	fi
	exit 1
fi

# Decide where to send the output based on whether -o was used
if [[ -n "$OUTPUT_FILE" ]]; then
	output_dir=$(dirname "$OUTPUT_FILE")
	mkdir -p "$output_dir"
	if [[ ! -d "$output_dir" ]]; then
		echo "Error: Could not create output directory for: $OUTPUT_FILE" >&2
		exit 1
	fi
	echo "$RESULTS" >"$OUTPUT_FILE"

	if [[ "$SILENT_MODE" = false ]]; then
		printf "[+] Total of %s unique domains found.\n" "$(echo "$RESULTS" | wc -l)" >&2
		printf "[+] Results saved to %s\n" "$OUTPUT_FILE" >&2
	fi
else
	echo "$RESULTS"
fi
