# ConfigMapの書き方

## サンプル

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . 8.8.8.8 1.1.1.1 {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
```

## `.:53`

`url:port`の書式で表す。  

- `.`はすべてのDNSゾーンを意味する
- `53`DNSの標準ポートとして53番を使用する。

## `error`

DNS処理中に発生したエラーをログ出力する。

## `health`

ヘルスチェック用のエンドポイントの提供を行う。

```console
root@k8s-master:/# curl http://10.244.0.4:8080/health
OK
```

### `lameduck`

Pod終了時のフックフールの指定。  
Graceful Shutdownのために色んなツールを入れることがある。

## `ready`

Readiness Probe用のエンドポイントを提供する。  
k8sはこのエンドポイントの結果を判断し、CoreDNSが名前解決可能だと判断すればServiceへ登録する処理を行う。

```console
root@k8s-master:/# curl http://10.244.0.4:8181/ready
OK
```

## `kubernetes`

k8s内部DNSを提供するプラグイン

- `cluster.local`  
  クラスタのDNSドメインを意味する。  

名前解決は以下で行われる。  
`<pod-name>.<namespace>.svc.cluster.local` -> `x.x.x.x`

### `pods`

Pod IPベースの名前解決を許可する。

`1-2-3-4.default.pod.cluster.local` -> `1.2.3.4`

- `insecure`は昔の互換モードを指す。  
   Podの厳密な存在確認を行わない。
- `verified` 新規の安全モードを指す。  
  全然使われてない。

### fallthrough

逆引きDNS用の設定。  
arpaを使ってIPアドレスからDNSを割り出す。

## prometheus

プロメテウスメトリクスの公開エンドポイントの提供。

```console
root@k8s-master:/# curl http://10.244.0.4:9153/metrics
# HELP coredns_build_info A metric with a constant '1' value labeled by version, revision, and goversion from which CoreDNS was built.
# TYPE coredns_build_info gauge
coredns_build_info{goversion="go1.21.11",revision="a6338e9",version="1.11.3"} 1
# HELP coredns_cache_entries The number of elements in the cache.
# TYPE coredns_cache_entries gauge
coredns_cache_entries{server="dns://:53",type="denial",view="",zones="."} 1
coredns_cache_entries{server="dns://:53",type="success",view="",zones="."} 0
# HELP coredns_cache_misses_total The count of cache misses. Deprecated, derive misses from cache hits/requests counters.
# TYPE coredns_cache_misses_total counter
coredns_cache_misses_total{server="dns://:53",view="",zones="."} 1
# HELP coredns_cache_requests_total The count of cache requests.
# TYPE coredns_cache_requests_total counter
coredns_cache_requests_total{server="dns://:53",view="",zones="."} 1
# HELP coredns_dns_request_duration_seconds Histogram of the time (in seconds) each request took per zone.
# TYPE coredns_dns_request_duration_seconds histogram
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.00025"} 0
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.0005"} 0
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.001"} 0
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.002"} 0
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.004"} 0
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.008"} 0
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.016"} 0
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.032"} 1
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.064"} 1
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.128"} 1
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.256"} 1
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="0.512"} 1
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="1.024"} 1
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="2.048"} 1
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="4.096"} 1
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="8.192"} 1
coredns_dns_request_duration_seconds_bucket{server="dns://:53",view="",zone=".",le="+Inf"} 1
coredns_dns_request_duration_seconds_sum{server="dns://:53",view="",zone="."} 0.020778782
coredns_dns_request_duration_seconds_count{server="dns://:53",view="",zone="."} 1
# HELP coredns_dns_request_size_bytes Size of the EDNS0 UDP buffer in bytes (64K for TCP) per zone and protocol.
# TYPE coredns_dns_request_size_bytes histogram
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="0"} 0
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="100"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="200"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="300"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="400"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="511"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="1023"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="2047"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="4095"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="8291"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="16000"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="32000"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="48000"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="64000"} 1
coredns_dns_request_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="+Inf"} 1
coredns_dns_request_size_bytes_sum{proto="udp",server="dns://:53",view="",zone="."} 56
coredns_dns_request_size_bytes_count{proto="udp",server="dns://:53",view="",zone="."} 1
# HELP coredns_dns_requests_total Counter of DNS requests made per zone, protocol and family.
# TYPE coredns_dns_requests_total counter
coredns_dns_requests_total{family="1",proto="udp",server="dns://:53",type="other",view="",zone="."} 1
# HELP coredns_dns_response_size_bytes Size of the returned response in bytes.
# TYPE coredns_dns_response_size_bytes histogram
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="0"} 0
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="100"} 0
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="200"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="300"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="400"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="511"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="1023"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="2047"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="4095"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="8291"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="16000"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="32000"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="48000"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="64000"} 1
coredns_dns_response_size_bytes_bucket{proto="udp",server="dns://:53",view="",zone=".",le="+Inf"} 1
coredns_dns_response_size_bytes_sum{proto="udp",server="dns://:53",view="",zone="."} 131
coredns_dns_response_size_bytes_count{proto="udp",server="dns://:53",view="",zone="."} 1
# HELP coredns_dns_responses_total Counter of response status codes.
# TYPE coredns_dns_responses_total counter
coredns_dns_responses_total{plugin="loadbalance",rcode="NXDOMAIN",server="dns://:53",view="",zone="."} 1
# HELP coredns_forward_healthcheck_broken_total Counter of the number of complete failures of the healthchecks.
# TYPE coredns_forward_healthcheck_broken_total counter
coredns_forward_healthcheck_broken_total 0
# HELP coredns_forward_max_concurrent_rejects_total Counter of the number of queries rejected because the concurrent queries were at maximum.
# TYPE coredns_forward_max_concurrent_rejects_total counter
coredns_forward_max_concurrent_rejects_total 0
# HELP coredns_health_request_duration_seconds Histogram of the time (in seconds) each request took.
# TYPE coredns_health_request_duration_seconds histogram
coredns_health_request_duration_seconds_bucket{le="0.00025"} 0
coredns_health_request_duration_seconds_bucket{le="0.0025"} 4852
coredns_health_request_duration_seconds_bucket{le="0.025"} 4992
coredns_health_request_duration_seconds_bucket{le="0.25"} 4992
coredns_health_request_duration_seconds_bucket{le="2.5"} 4992
coredns_health_request_duration_seconds_bucket{le="+Inf"} 4992
coredns_health_request_duration_seconds_sum 5.755878751000004
coredns_health_request_duration_seconds_count 4992
# HELP coredns_health_request_failures_total The number of times the health check failed.
# TYPE coredns_health_request_failures_total counter
coredns_health_request_failures_total 0
# HELP coredns_hosts_reload_timestamp_seconds The timestamp of the last reload of hosts file.
# TYPE coredns_hosts_reload_timestamp_seconds gauge
coredns_hosts_reload_timestamp_seconds 0
# HELP coredns_kubernetes_rest_client_rate_limiter_duration_seconds Client side rate limiter latency in seconds. Broken down by verb and host.
# TYPE coredns_kubernetes_rest_client_rate_limiter_duration_seconds histogram
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.005"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.01"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.025"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.05"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.1"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.25"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.5"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="1"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="2.5"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="5"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="10"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="+Inf"} 3
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_sum{host="10.96.0.1:443",verb="GET"} 5.345999999999999e-06
coredns_kubernetes_rest_client_rate_limiter_duration_seconds_count{host="10.96.0.1:443",verb="GET"} 3
# HELP coredns_kubernetes_rest_client_request_duration_seconds Request latency in seconds. Broken down by verb and host.
# TYPE coredns_kubernetes_rest_client_request_duration_seconds histogram
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.005"} 0
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.01"} 3
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.025"} 3
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.05"} 3
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.1"} 3
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.25"} 3
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="0.5"} 3
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="1"} 3
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="2.5"} 3
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="5"} 3
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="10"} 3
coredns_kubernetes_rest_client_request_duration_seconds_bucket{host="10.96.0.1:443",verb="GET",le="+Inf"} 3
coredns_kubernetes_rest_client_request_duration_seconds_sum{host="10.96.0.1:443",verb="GET"} 0.020004016
coredns_kubernetes_rest_client_request_duration_seconds_count{host="10.96.0.1:443",verb="GET"} 3
# HELP coredns_kubernetes_rest_client_requests_total Number of HTTP requests, partitioned by status code, method, and host.
# TYPE coredns_kubernetes_rest_client_requests_total counter
coredns_kubernetes_rest_client_requests_total{code="200",host="10.96.0.1:443",method="GET"} 39
# HELP coredns_local_localhost_requests_total Counter of localhost.<domain> requests.
# TYPE coredns_local_localhost_requests_total counter
coredns_local_localhost_requests_total 0
# HELP coredns_panics_total A metrics that counts the number of panics.
# TYPE coredns_panics_total counter
coredns_panics_total 0
# HELP coredns_plugin_enabled A metric that indicates whether a plugin is enabled on per server and zone basis.
# TYPE coredns_plugin_enabled gauge
coredns_plugin_enabled{name="cache",server="dns://:53",view="",zone="."} 1
coredns_plugin_enabled{name="errors",server="dns://:53",view="",zone="."} 1
coredns_plugin_enabled{name="forward",server="dns://:53",view="",zone="."} 1
coredns_plugin_enabled{name="kubernetes",server="dns://:53",view="",zone="."} 1
coredns_plugin_enabled{name="loadbalance",server="dns://:53",view="",zone="."} 1
coredns_plugin_enabled{name="loop",server="dns://:53",view="",zone="."} 1
coredns_plugin_enabled{name="prometheus",server="dns://:53",view="",zone="."} 1
# HELP coredns_proxy_conn_cache_misses_total Counter of connection cache misses per upstream and protocol.
# TYPE coredns_proxy_conn_cache_misses_total counter
coredns_proxy_conn_cache_misses_total{proto="udp",proxy_name="forward",to="8.8.8.8:53"} 1
# HELP coredns_proxy_request_duration_seconds Histogram of the time each request took.
# TYPE coredns_proxy_request_duration_seconds histogram
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.00025"} 0
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.0005"} 0
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.001"} 0
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.002"} 0
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.004"} 0
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.008"} 0
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.016"} 1
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.032"} 1
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.064"} 1
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.128"} 1
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.256"} 1
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="0.512"} 1
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="1.024"} 1
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="2.048"} 1
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="4.096"} 1
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="8.192"} 1
coredns_proxy_request_duration_seconds_bucket{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53",le="+Inf"} 1
coredns_proxy_request_duration_seconds_sum{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53"} 0.014560221
coredns_proxy_request_duration_seconds_count{proxy_name="forward",rcode="NXDOMAIN",to="8.8.8.8:53"} 1
# HELP coredns_reload_failed_total Counter of the number of failed reload attempts.
# TYPE coredns_reload_failed_total counter
coredns_reload_failed_total 0
# HELP go_gc_duration_seconds A summary of the pause duration of garbage collection cycles.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 3.8413e-05
go_gc_duration_seconds{quantile="0.25"} 7.4755e-05
go_gc_duration_seconds{quantile="0.5"} 0.000175153
go_gc_duration_seconds{quantile="0.75"} 0.000446623
go_gc_duration_seconds{quantile="1"} 0.001092662
go_gc_duration_seconds_sum 0.012626797
go_gc_duration_seconds_count 44
# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
go_goroutines 41
# HELP go_info Information about the Go environment.
# TYPE go_info gauge
go_info{version="go1.21.11"} 1
# HELP go_memstats_alloc_bytes Number of bytes allocated and still in use.
# TYPE go_memstats_alloc_bytes gauge
go_memstats_alloc_bytes 6.455016e+06
# HELP go_memstats_alloc_bytes_total Total number of bytes allocated, even if freed.
# TYPE go_memstats_alloc_bytes_total counter
go_memstats_alloc_bytes_total 9.6257544e+07
# HELP go_memstats_buck_hash_sys_bytes Number of bytes used by the profiling bucket hash table.
# TYPE go_memstats_buck_hash_sys_bytes gauge
go_memstats_buck_hash_sys_bytes 1.464176e+06
# HELP go_memstats_frees_total Total number of frees.
# TYPE go_memstats_frees_total counter
go_memstats_frees_total 660351
# HELP go_memstats_gc_sys_bytes Number of bytes used for garbage collection system metadata.
# TYPE go_memstats_gc_sys_bytes gauge
go_memstats_gc_sys_bytes 4.41572e+06
# HELP go_memstats_heap_alloc_bytes Number of heap bytes allocated and still in use.
# TYPE go_memstats_heap_alloc_bytes gauge
go_memstats_heap_alloc_bytes 6.455016e+06
# HELP go_memstats_heap_idle_bytes Number of heap bytes waiting to be used.
# TYPE go_memstats_heap_idle_bytes gauge
go_memstats_heap_idle_bytes 6.586368e+06
# HELP go_memstats_heap_inuse_bytes Number of heap bytes that are in use.
# TYPE go_memstats_heap_inuse_bytes gauge
go_memstats_heap_inuse_bytes 8.978432e+06
# HELP go_memstats_heap_objects Number of allocated objects.
# TYPE go_memstats_heap_objects gauge
go_memstats_heap_objects 32847
# HELP go_memstats_heap_released_bytes Number of heap bytes released to OS.
# TYPE go_memstats_heap_released_bytes gauge
go_memstats_heap_released_bytes 5.431296e+06
# HELP go_memstats_heap_sys_bytes Number of heap bytes obtained from system.
# TYPE go_memstats_heap_sys_bytes gauge
go_memstats_heap_sys_bytes 1.55648e+07
# HELP go_memstats_last_gc_time_seconds Number of seconds since 1970 of last garbage collection.
# TYPE go_memstats_last_gc_time_seconds gauge
go_memstats_last_gc_time_seconds 1.792117209177042e+09
# HELP go_memstats_lookups_total Total number of pointer lookups.
# TYPE go_memstats_lookups_total counter
go_memstats_lookups_total 0
# HELP go_memstats_mallocs_total Total number of mallocs.
# TYPE go_memstats_mallocs_total counter
go_memstats_mallocs_total 693198
# HELP go_memstats_mcache_inuse_bytes Number of bytes in use by mcache structures.
# TYPE go_memstats_mcache_inuse_bytes gauge
go_memstats_mcache_inuse_bytes 7200
# HELP go_memstats_mcache_sys_bytes Number of bytes used for mcache structures obtained from system.
# TYPE go_memstats_mcache_sys_bytes gauge
go_memstats_mcache_sys_bytes 15600
# HELP go_memstats_mspan_inuse_bytes Number of bytes in use by mspan structures.
# TYPE go_memstats_mspan_inuse_bytes gauge
go_memstats_mspan_inuse_bytes 215376
# HELP go_memstats_mspan_sys_bytes Number of bytes used for mspan structures obtained from system.
# TYPE go_memstats_mspan_sys_bytes gauge
go_memstats_mspan_sys_bytes 228144
# HELP go_memstats_next_gc_bytes Number of heap bytes when next garbage collection will take place.
# TYPE go_memstats_next_gc_bytes gauge
go_memstats_next_gc_bytes 1.1093656e+07
# HELP go_memstats_other_sys_bytes Number of bytes used for other system allocations.
# TYPE go_memstats_other_sys_bytes gauge
go_memstats_other_sys_bytes 1.582224e+06
# HELP go_memstats_stack_inuse_bytes Number of bytes in use by the stack allocator.
# TYPE go_memstats_stack_inuse_bytes gauge
go_memstats_stack_inuse_bytes 1.212416e+06
# HELP go_memstats_stack_sys_bytes Number of bytes obtained from system for stack allocator.
# TYPE go_memstats_stack_sys_bytes gauge
go_memstats_stack_sys_bytes 1.212416e+06
# HELP go_memstats_sys_bytes Number of bytes obtained from system.
# TYPE go_memstats_sys_bytes gauge
go_memstats_sys_bytes 2.448308e+07
# HELP go_threads Number of OS threads created.
# TYPE go_threads gauge
go_threads 12
# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 13.45
# HELP process_max_fds Maximum number of open file descriptors.
# TYPE process_max_fds gauge
process_max_fds 1.048576e+06
# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 14
# HELP process_resident_memory_bytes Resident memory size in bytes.
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 5.5304192e+07
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1.79211229847e+09
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 1.31817472e+09
# HELP process_virtual_memory_max_bytes Maximum amount of virtual memory available in bytes.
# TYPE process_virtual_memory_max_bytes gauge
process_virtual_memory_max_bytes 1.8446744073709552e+19
```

## `forward`

k8s内部以外の名前解決を転送する先を決める設定。
`.`はすべてを意味する。

- `/etc/resolv.conf`  
  ローカルリゾルバに任せる形
- `8.8.8.8`など  
  Google DNSなどIPアドレスを直接書くことも可能。

```console
root@k8s-master:/# nslookup google.com
Server:         127.0.0.11
Address:        127.0.0.11#53

Non-authoritative answer:
Name:   google.com
Address: 142.251.119.139
Name:   google.com
Address: 142.251.119.138
Name:   google.com
Address: 142.251.119.100
Name:   google.com
Address: 142.251.119.113
Name:   google.com
Address: 142.251.119.101
Name:   google.com
Address: 142.251.119.102
Name:   google.com
Address: 2404:6800:400a:1000::65
Name:   google.com
Address: 2404:6800:400a:1000::8a
Name:   google.com
Address: 2404:6800:400a:1000::66
Name:   google.com
Address: 2404:6800:400a:1000::64
```

## `loop`

DNSループ検出器の設定。  
誤設定でDNSがループしてしまった場合、通信が出来ないので起動時にエラーログを書いて終了する。

クラスタ全体のDNS障害を防ぐ安全装置設定のため必須。

## `reload`

CoreDNSの再起動を無しに設定を反映するホットリロード設定の有効化。

## `loadbalance`

DNS応答をシャッフルする設定。

- 10.1.1.1
- 10.1.1.2
- 10.1.1.3

があるとして、ランダムに応答させることでクライアント接続の偏りを減らす。
