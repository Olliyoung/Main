# Static Routing Notes

## AD values you actually need
- Connected **0**
- Static **1**
- EIGRP **90**
- OSPF **110**
- RIP **120**

Lower number wins.  
Floating static = higher AD than the main route so it only works when the main one dies.

## Route types
- Next-hop only = recursive (router has to look up how to reach the next-hop)
- Exit interface only = directly connected
- Both exit interface + next-hop = fully specified (no recursive lookup, better on Ethernet)

Default route = `0.0.0.0/0` or `::/0` → becomes gateway of last resort.

## IPv6
You have to turn routing on first:

`ipv6 unicast-routing`

Otherwise static routes don’t work properly.

## Classic mistakes they love testing
- Putting a network address as next-hop (e.g. `172.16.2.0`) → route never installs
- Using the wrong interface (the neighbour’s serial instead of yours)
- Floating static with AD lower than the dynamic protocol → it takes over and stays up
- Missing the return route on the other side → one-way traffic
- Forgetting `ipv6 unicast-routing`

## When a PC talks to something on another network
- Destination IP stays the final server the whole time
- Destination MAC is the default gateway (your router’s LAN MAC)

## Stub network (one way out)
Cheapest on CPU and bandwidth:
- Inside router just needs a default route toward the edge
- Edge needs a default to the internet + static routes back to the inside networks

No need for OSPF/EIGRP between them.

## Useful commands
`ip route 172.16.1.0 255.255.255.0 S0/0/0 121` ← floating (AD higher than RIP 120)

`ipv6 route 2001:db8:1::/64 G0/0 2001:db8:2::1`

`ipv6 route ::/0 S0/0/0`

That’s basically everything that kept coming up.  
Know the AD numbers and “next-hop has to be a real IP, not a network address” and you’ll be fine.
