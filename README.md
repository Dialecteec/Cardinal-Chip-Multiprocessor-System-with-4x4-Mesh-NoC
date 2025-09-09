# Cardinal-Chip-Multiprocessor-System-with-4x4-Mesh-NoC
A synthesizable 16-core CMP based on Cardinal processors, memory-mapped NICs, and mesh NOC.
•	Processor: Single-issue, in-order 4-stage pipeline implementing the full Cardinal ISA (ALU, loads/stores, branches/jumps); memory-mapped NIC/memory via standard loads/stores with ready/valid handshakes; fully synthesizable RTL.
•	NIC: Memory-mapped network interface exposing a small register space (CPU-accessible via standard loads/stores) and send/ready handshakes for packet inject/eject. Implements backpressure and defined blocking behavior; Full-duplex CPU↔NoC transfers when resources permit; selects VC (virtual channel) per header to preserve correctness under contention.
•	NoC: 4×4 mesh fabric with two virtual channels per link; packet switching with two VCTs. Router parses source-routed headers (vc/dir/hop) and updates hop count each hop; output ports use round-robin arbitration with send/ready flow control to propagate backpressure.
•	Post-synthesis/STA (block-level): CPU critical path 12.13 ns (~82.4 MHz); NOC 4.38 ns (~228.3 MHz) (Fmax ≈ 1000/Delay[ns]).
•	Design improvement: Replaced packet switching with wormhole switching; shrank buffers to 8-bit flits with an 8-bit route-compute stage; per-hop latency 7→2 cycles; area & leakage ~50% of the original packet-switched NoC; dynamic power ~34.3% of baseline.
