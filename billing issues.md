* EBS snapshots do not report their size, only the volume_size they came from. This makes calculating their cost impossible unless it's the first snapshot from that volume.

* EBS snapshots are stored in S3 and priced by region, but they do not report their region.

