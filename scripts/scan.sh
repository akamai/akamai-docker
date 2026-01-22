# $1 should be the scout command: cves, recommendations, quickview
if [ -z "$1" ]; then
    echo "Usage: $0 <scout-command>"
    echo "Example: $0 cves"
    exit 1
fi
for image in $(docker images --format "{{.Repository}}:{{.Tag}}" | grep "akamai" | grep -v -- "-chain" ); do
    echo "Reviewing $image"
    docker scout $1 "$image"
done