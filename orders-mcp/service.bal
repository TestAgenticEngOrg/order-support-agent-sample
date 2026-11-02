import ballerina/lang.regexp;
import ballerina/mcp;

configurable int port = 9090;

final regexp:RegExp orderIdPattern = re `[0-9]{1,10}`;

listener mcp:StreamableHttpListener ordersListener = check new (port);

// Stateless, so any replica can answer any request. All tools are read-only.
@mcp:StreamableHttpServiceConfig {
    info: {
        name: "Orders MCP Server",
        version: "0.1.0"
    },
    sessionMode: mcp:STATELESS,
    options: {
        instructions: "Read-only access to customer orders and shipment tracking."
    }
}
service mcp:StreamableHttpService /mcp on ordersListener {

    # Get the full details of one order: status, items, total and shipping address.
    #
    # + orderId - The order number such as "1042"
    # + return - The order, or an error if no order has that number
    remote function getOrder(string orderId) returns Order|error {
        string id = check normalizeOrderId(orderId);
        Order? 'order = orders[id];
        if 'order is () {
            return error(string `No order found with number ${id}`);
        }
        return 'order;
    }

    # List all orders placed by a customer, newest first.
    #
    # + customerEmail - The customer's email address
    # + return - A short summary of each order, empty if the customer has none
    remote function listCustomerOrders(string customerEmail) returns OrderSummary[]|error {
        string email = customerEmail.trim().toLowerAscii();
        if email.length() == 0 || email.length() > 254 {
            return error("Provide a valid customer email address");
        }
        return from Order o in orders
            where o.customerEmail == email
            order by o.placedOn descending
            select {
                orderId: o.orderId,
                status: o.status,
                placedOn: o.placedOn,
                itemCount: o.items.length(),
                total: o.total,
                currency: o.currency
            };
    }

    # Track the shipment for an order: carrier, tracking number, status and delivery date.
    #
    # + orderId - The order number such as "1042"
    # + return - The shipment, or an error if the order has not shipped
    remote function trackShipment(string orderId) returns Shipment|error {
        string id = check normalizeOrderId(orderId);
        if !orders.hasKey(id) {
            return error(string `No order found with number ${id}`);
        }
        Shipment? shipment = shipments[id];
        if shipment is () {
            return error(string `Order ${id} has not shipped yet`);
        }
        return shipment;
    }
}

// Accepts "1042" or "#1042" and rejects anything else.
isolated function normalizeOrderId(string orderId) returns string|error {
    string id = orderId.trim();
    if id.startsWith("#") {
        id = id.substring(1);
    }
    if !orderIdPattern.isFullMatch(id) {
        return error("Order numbers contain digits only, for example 1042");
    }
    return id;
}
