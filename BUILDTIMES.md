What is taking time during builds?

* python images without a build stage (cps, httpie)
  * we incur the build price both for single derivatives and for shell
  * for images with a build stage, cache is reused for shell
* upx executable compression
  * all go images, in particular CLI and terraform
  * for terraform, specifically the following take a VERY long time (20 minutes?), but are worth it (20% of original size, each plugin is 20MB)

  ```
  # upx creates a self-extracting compressed executable
  && upx --brute -o/usr/local/bin/akamaiDns.upx /usr/local/bin/akamaiDns \
  # we need to include the cli.json file as well
  && cp "${GOPATH}/src/github.com/akamai/cli-dns/cli.json" /cli.json
  ```