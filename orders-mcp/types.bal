// Records returned by the orders MCP tools. The agent sees these as JSON.

type OrderItem record {|
    string sku;
    string name;
    int quantity;
    decimal unitPrice;
|};

type Order record {|
    string orderId;
    string customerName;
    string customerEmail;
    string status;
    string placedOn;
    OrderItem[] items;
    decimal total;
    string currency;
    string shippingAddress;
|};

type OrderSummary record {|
    string orderId;
    string status;
    string placedOn;
    int itemCount;
    decimal total;
    string currency;
|};

type ShipmentEvent record {|
    string timestamp;
    string location;
    string description;
|};

type Shipment record {|
    string orderId;
    string carrier;
    string trackingNumber;
    string status;
    string? estimatedDelivery;
    string? deliveredOn;
    ShipmentEvent[] events;
|};
