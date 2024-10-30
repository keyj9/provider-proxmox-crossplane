# High-Availability Database Cluster with Ceph Storage

## Scenario Description
Deploy a highly available PostgreSQL database cluster with synchronous replication between two sites, automated failover, and performance-optimized storage configuration.

### Key Components
- Primary and secondary database nodes
- Synchronous Ceph replication
- Automated failover handling
- Performance-optimized storage pools
- Dedicated replication network

### Implementation Files
1. Primary Database VM:
```yaml:examples/ceph/disaster-recovery/vm-critical.yaml
startLine: 1
endLine: 34
```

2. Storage Configuration:
```yaml:examples/ceph/disaster-recovery/storage-primary.yaml
startLine: 1
endLine: 21
```

### Deployment Steps
1. Create storage pools
2. Configure replication
3. Deploy primary VM
4. Configure monitoring
5. Test failover

### Performance Considerations
- IOPS limits configured for predictable performance
- Separate disks for data and logs
- Network QoS for replication traffic

### Monitoring Requirements
- Replication lag monitoring
- IOPS utilization tracking
- Network bandwidth monitoring