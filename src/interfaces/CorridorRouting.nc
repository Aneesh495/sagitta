#include "sagitta_types.h"
#include "sagitta_messages.h"

/**
 * CorridorRouting interface provides linear multi-hop routing,
 * bidirectional neighbor tracking, and adaptive route repair.
 */
interface CorridorRouting {
  /**
   * Initializes routing state with node network position.
   * @param localNodeId Unique node identifier
   * @param spanIndex Index of tower span (0 = gateway, 1 = first tower, etc.)
   * @return SUCCESS if initialized
   */
  command error_t initRouting(uint16_t localNodeId, uint16_t spanIndex);

  /**
   * Forwards a payload towards the substation gateway sink.
   * @param payload Packet payload bytes
   * @param length Payload length
   * @return SUCCESS if routed to next-hop
   */
  command error_t routeToGateway(const uint8_t* payload, uint8_t length);

  /**
   * Event signaled when a telemetry packet addressed to gateway arrives at sink.
   * @param payload Packet payload bytes
   * @param length Payload length
   * @param originNodeId ID of source node
   */
  event void telemetryDelivered(const uint8_t* payload, uint8_t length, uint16_t originNodeId);

  /**
   * Queries the current preferred upstream next-hop node ID.
   * @return Node ID of parent gateway-direction neighbor
   */
  command uint16_t getUpstreamParent();
}
