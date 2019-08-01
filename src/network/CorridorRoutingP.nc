#include "sagitta_types.h"
#include "sagitta_config.h"
#include "sagitta_messages.h"

/**
 * CorridorRoutingP implements Linear Collection Tree Protocol (L-CTP)
 * optimized for the physical linear geometry of transmission pylons.
 */
module CorridorRoutingP {
  provides {
    interface CorridorRouting;
  }
  uses {
    interface MacTsch;
  }
}
implementation {
  uint16_t m_localNodeId;
  uint16_t m_spanIndex;
  uint16_t m_upstreamParentId;
  uint16_t m_downstreamChildId;

  command error_t CorridorRouting.initRouting(uint16_t localNodeId, uint16_t spanIndex) {
    m_localNodeId = localNodeId;
    m_spanIndex = spanIndex;

    /* In linear corridor, upstream parent is spanIndex - 1 (gateway is at span 0) */
    if (spanIndex > 0) {
      m_upstreamParentId = (spanIndex == 1) ? 0 : (localNodeId - 1);
    } else {
      m_upstreamParentId = 0; /* Root sink */
    }
    m_downstreamChildId = localNodeId + 1;
    return SAGITTA_SUCCESS;
  }

  command error_t CorridorRouting.routeToGateway(const uint8_t* payload, uint8_t length) {
    if (!payload || length == 0) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* Enqueue to upstream parent */
    return call MacTsch.sendPacket(payload, length, FALSE);
  }

  command uint16_t CorridorRouting.getUpstreamParent() {
    return m_upstreamParentId;
  }

  event void MacTsch.sendDone(const uint8_t* packet, error_t status) {
    /* Route ack and ETX metric updates */
  }

  event void MacTsch.packetReceived(const uint8_t* packet, uint8_t length, int8_t rssiDbm, uint8_t lqi) {
    if (!packet || length < sizeof(sagitta_header_t)) {
      return;
    }
    const sagitta_header_t* hdr = (const sagitta_header_t*)packet;

    if (m_spanIndex == 0) {
      /* Reached gateway root */
      signal CorridorRouting.telemetryDelivered(packet, length, hdr->src_node_id);
    } else if (hdr->dst_node_id == m_localNodeId || hdr->dst_node_id == 0) {
      /* Forward upstream toward gateway */
      call MacTsch.sendPacket(packet, length, (hdr->flags & 0x01) ? TRUE : FALSE);
    }
  }
}
