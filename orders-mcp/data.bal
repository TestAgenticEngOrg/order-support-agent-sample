// Mock order data. Held in memory because the platform runs this component on a
// read-only filesystem. All names and addresses are fictional.

final readonly & map<Order> orders = {
    "1029": {
        orderId: "1029",
        customerName: "Sam Lee",
        customerEmail: "sam.lee@example.com",
        status: "CANCELLED",
        placedOn: "2026-10-05",
        items: [{sku: "KB-201", name: "Mechanical Keyboard", quantity: 1, unitPrice: 89.00}],
        total: 89.00,
        currency: "USD",
        shippingAddress: "12 Harbor Road, Seattle, WA"
    },
    "1031": {
        orderId: "1031",
        customerName: "Priya Raman",
        customerEmail: "priya.raman@example.com",
        status: "DELIVERED",
        placedOn: "2026-10-08",
        items: [
            {sku: "HP-110", name: "Wireless Headphones", quantity: 1, unitPrice: 129.00},
            {sku: "CB-005", name: "USB-C Cable", quantity: 2, unitPrice: 12.50}
        ],
        total: 154.00,
        currency: "USD",
        shippingAddress: "48 Elm Street, Austin, TX"
    },
    "1038": {
        orderId: "1038",
        customerName: "Alex Doe",
        customerEmail: "alex.doe@example.com",
        status: "DELIVERED",
        placedOn: "2026-10-14",
        items: [{sku: "MS-330", name: "Ergonomic Mouse", quantity: 1, unitPrice: 49.00}],
        total: 49.00,
        currency: "USD",
        shippingAddress: "7 Lake View Drive, Denver, CO"
    },
    "1042": {
        orderId: "1042",
        customerName: "Alex Doe",
        customerEmail: "alex.doe@example.com",
        status: "SHIPPED",
        placedOn: "2026-10-27",
        items: [
            {sku: "MN-270", name: "27-inch Monitor", quantity: 1, unitPrice: 279.00},
            {sku: "ST-010", name: "Monitor Stand", quantity: 1, unitPrice: 39.00}
        ],
        total: 318.00,
        currency: "USD",
        shippingAddress: "7 Lake View Drive, Denver, CO"
    },
    "1045": {
        orderId: "1045",
        customerName: "Priya Raman",
        customerEmail: "priya.raman@example.com",
        status: "PROCESSING",
        placedOn: "2026-10-31",
        items: [{sku: "LP-900", name: "Laptop Sleeve", quantity: 1, unitPrice: 35.00}],
        total: 35.00,
        currency: "USD",
        shippingAddress: "48 Elm Street, Austin, TX"
    },
    "1047": {
        orderId: "1047",
        customerName: "Sam Lee",
        customerEmail: "sam.lee@example.com",
        status: "SHIPPED",
        placedOn: "2026-10-24",
        items: [{sku: "WC-120", name: "HD Webcam", quantity: 1, unitPrice: 69.00}],
        total: 69.00,
        currency: "USD",
        shippingAddress: "12 Harbor Road, Seattle, WA"
    },
    "1050": {
        orderId: "1050",
        customerName: "Maria Garcia",
        customerEmail: "maria.garcia@example.com",
        status: "DELIVERED",
        placedOn: "2026-10-22",
        items: [{sku: "DK-400", name: "Standing Desk", quantity: 1, unitPrice: 449.00}],
        total: 449.00,
        currency: "USD",
        shippingAddress: "90 Pine Avenue, Chicago, IL"
    }
};

final readonly & map<Shipment> shipments = {
    "1031": {
        orderId: "1031",
        carrier: "FastShip",
        trackingNumber: "FS100031",
        status: "DELIVERED",
        estimatedDelivery: (),
        deliveredOn: "2026-10-12",
        events: [
            {timestamp: "2026-10-09T09:00:00Z", location: "Dallas, TX", description: "Picked up"},
            {timestamp: "2026-10-12T15:20:00Z", location: "Austin, TX", description: "Delivered"}
        ]
    },
    "1038": {
        orderId: "1038",
        carrier: "FastShip",
        trackingNumber: "FS100038",
        status: "DELIVERED",
        estimatedDelivery: (),
        deliveredOn: "2026-10-18",
        events: [
            {timestamp: "2026-10-15T10:30:00Z", location: "Salt Lake City, UT", description: "Picked up"},
            {timestamp: "2026-10-18T11:05:00Z", location: "Denver, CO", description: "Delivered"}
        ]
    },
    "1042": {
        orderId: "1042",
        carrier: "FastShip",
        trackingNumber: "FS100042",
        status: "IN_TRANSIT",
        estimatedDelivery: "2026-11-04",
        deliveredOn: (),
        events: [
            {timestamp: "2026-10-29T08:15:00Z", location: "Phoenix, AZ", description: "Picked up"},
            {timestamp: "2026-10-31T19:40:00Z", location: "Albuquerque, NM", description: "Arrived at sorting facility"},
            {timestamp: "2026-11-01T22:10:00Z", location: "Albuquerque, NM", description: "Departed sorting facility"}
        ]
    },
    "1047": {
        orderId: "1047",
        carrier: "NorthPost",
        trackingNumber: "NP7781047",
        status: "DELAYED",
        estimatedDelivery: "2026-11-06",
        deliveredOn: (),
        events: [
            {timestamp: "2026-10-26T13:00:00Z", location: "Portland, OR", description: "Picked up"},
            {timestamp: "2026-10-28T07:45:00Z", location: "Portland, OR", description: "Delayed due to weather"}
        ]
    },
    "1050": {
        orderId: "1050",
        carrier: "NorthPost",
        trackingNumber: "NP7781050",
        status: "DELIVERED",
        estimatedDelivery: (),
        deliveredOn: "2026-10-30",
        events: [
            {timestamp: "2026-10-24T12:00:00Z", location: "Milwaukee, WI", description: "Picked up"},
            {timestamp: "2026-10-30T16:30:00Z", location: "Chicago, IL", description: "Delivered"}
        ]
    }
};
