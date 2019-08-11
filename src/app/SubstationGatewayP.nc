#include "sagitta_types.h"
#include "sagitta_messages.h"

/**
 * SubstationGatewayP aggregates telemetry packets delivered from the
 * linear corridor mesh and formats them for SCADA / DNP3 export.
 */
module SubstationGatewayP {
  provides {
    interface Init;
  }
  uses {
    interface CorridorRouting;
    interface MacTsch;
    interface TimeSync;
  }
}
implementation {
  uint32_t m_packetsReceived;
  uint32_t m_alarmsLogged;

  command error_t Init.init() {
    m_packetsReceived = 0;
    m_alarmsLogged = 0;
    call CorridorRouting.initRouting(0, 0); /* Gateway is node 0 at span 0 */
    return SAGITTA_SUCCESS;
  }

  event void CorridorRouting.telemetryDelivered(const uint8_t* payload, uint8_t length, uint16_t originNodeId) {
    if (!payload || length < sizeof(sagitta_header_t)) {
      return;
    }
    m_packetsReceived++;
    const sagitta_header_t* hdr = (const sagitta_header_t*)payload;

    if (hdr->msg_type == MSG_TYPE_DLR_STATE) {
      const msg_dlr_state_t* dlr = (const msg_dlr_state_t*)payload;
      if (dlr->alarm_state > ALARM_LEVEL_NORMAL) {
        m_alarmsLogged++;
      }
    } else if (hdr->msg_type == MSG_TYPE_WAVEFRONT_EVENT) {
      m_alarmsLogged++;
    }
  }

  event void MacTsch.sendDone(const uint8_t* packet, error_t status) {
  }

  event void MacTsch.packetReceived(const uint8_t* packet, uint8_t length, int8_t rssiDbm, uint8_t lqi) {
  }
}
