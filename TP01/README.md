
#  Lab Work — WAN Queue Analysis with OMNeT++

**Network:** ThreeCityWAN | **Simulator:** OMNeT++ 6.3.0 | **Framework:** INET

---

##  Objective

Simulate a WAN (Wide Area Network) interconnecting three local networks and analyze **queue buildup and congestion** on router interfaces under increasing traffic load.

---

##  Network Topology

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│  LAN01                                               │
│  Host A ──┐                                          │
│            ├── R1 ──────── R2 ──── Host C  (LAN03)  │
│  Host B ──┘                                          │
│  LAN02                                               │
│                                                      │
└──────────────────────────────────────────────────────┘
```

| Network | Host | Role |
|---|---|---|
| **LAN01** | **Host A** | Traffic source — sends flows to LAN03 |
| **LAN02** | **Host B** | Traffic source — sends flows to LAN03 |
| **LAN03** | **Host C** | Traffic sink — receives all incoming flows |
| **WAN Core** | **R1, R2** | Routers interconnecting the three LANs |

---

##  Simulation Configuration (`omnetpp.ini`)

### Phase 1 — Light Traffic
- Protocol: **PingApp**
- Host A → Host C : 1 ping every **1s**
- Host B → Host C : 1 ping every **2s**
- Result: **no congestion**, all queues = 0 packets

### Phase 2 — Heavy Traffic (stress test)
- Protocol: **UdpBasicApp** — 3 concurrent flows per host
- Packet size: **1400 bytes**
- Send interval: **0.001s** per flow ≈ 11 Mbps per flow
- WAN link bandwidth limited to: **1 Mbps**
- Result: **severe congestion** at the WAN bottleneck

---

##  Results

### Queue Length over Time

![Queue Analysis](queue_analysis.png)

### Summary Table

| Interface | Role | Max Queue | Status |
|---|---|---|---|
| `R1.eth[2]` | LAN01 + LAN02 → LAN03 bottleneck | **154 packets** | 🔴 Saturated |
| `Host B.eth[0]` | LAN02 internal | ~5 packets | 🟡 Minor burst |
| All others | — | 0–2 packets | 🟢 Normal |

### Key Observations

- **`R1.eth[2]`** is the **bottleneck** — all traffic from LAN01 (Host A) and LAN02 (Host B) toward LAN03 (Host C) converges on this single WAN link
- The queue grows **linearly** without stabilizing → incoming rate far exceeds the 1 Mbps capacity
- This causes **packet drops** once the buffer is full — classic **congestion collapse**

---

## 🛠️ Files

| File | Description |
|---|---|
| `omnetpp.ini` | Simulation parameters |
| `General-#0.vec` | Raw vector output from OMNeT++ |
| `queue.csv` | Queue data exported via `opp_scavetool` |
| `queue_analysis.png` | Result graph |

### Export queue data
```bash
opp_scavetool export -f 'name =~ "*queueLength*"' -o queue.csv General-#0.vec
```

---

##  Conclusion

This lab demonstrates a classic **congestion scenario** in WAN networks : when multiple high-throughput flows from **LAN01 (Host A)** and **LAN02 (Host B)** share a low-bandwidth WAN link toward **LAN03 (Host C)**, the router queue grows indefinitely without traffic control.

**Possible solutions :**
- Increase WAN link bandwidth (`datarate = 100Mbps`)
- Apply **QoS / traffic shaping** to limit each host's throughput
- Use **RED / AQM** (Active Queue Management) to drop packets early

---

*Simulated with OMNeT++ 6.3.0 + INET Framework*
