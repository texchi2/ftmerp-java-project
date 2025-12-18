# Apache OFBiz Core Systems Reference

Understanding the five core systems that power Apache OFBiz ERP.

**Reference**: [Apache OFBiz Developer Manual](https://ofbizextra.org/ofbiz_adocs/docs/asciidoc/developer-manual.pdf)

---

## Overview

Apache OFBiz at its core is a collection of five integrated systems:

1. **Web Server** (Apache Tomcat)
2. **Web MVC Framework** (for routing and handling requests)
3. **Entity Engine** (to define, load and manipulate data)
4. **Service Engine** (to define and control business logic)
5. **Widget System** (to draw and interact with a user interface)

These systems work together to provide a complete enterprise application framework.

---

## 1. Web Server - Apache Tomcat

### Purpose
Provides the HTTP server and servlet container for running OFBiz web applications.

### Key Features
- **HTTP/HTTPS Support**: Handles web requests on ports 8080 (HTTP) and 8443 (HTTPS)
- **Servlet Container**: Runs Java servlets and JSPs
- **Session Management**: Manages user sessions
- **Connection Pooling**: Efficiently manages database connections

### Configuration
```
Location: framework/catalina/ofbiz-component.xml
         framework/webapp/config/

Ports:
  HTTP:  8080
  HTTPS: 8443
  AJP:   8009 (for Apache httpd integration)
```

### OFBiz Customization
OFBiz embeds Tomcat rather than deploying as a WAR file, allowing:
- Direct control over server lifecycle
- Custom component loading
- Integration with OFBiz service engine
- Hot deployment of components

### Example: Starting OFBiz
```bash
cd /home/user/ftmerp-java-project
./gradlew ofbiz

# This starts:
# 1. Embedded Tomcat
# 2. Loads all components
# 3. Initializes entity engine
# 4. Starts service dispatcher
# 5. Deploys web applications
```

---

## 2. Web MVC Framework

### Purpose
Routes HTTP requests to appropriate handlers and generates responses.

### Architecture

```
HTTP Request
     ↓
Controller (control.xml)
     ↓
Request Handler
     ↓
   ┌──────────────┬──────────────┬──────────────┐
   │              │              │              │
Service Call  View Render   Direct Response  Event Handler
   ↓              ↓              ↓              ↓
Entity Data   Screen Widget   JSON/XML      Business Logic
```

### Controller Configuration

**File**: `webapp/[component]/WEB-INF/controller.xml`

```xml
<site-conf xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:noNamespaceSchemaLocation="http://ofbiz.apache.org/dtds/site-conf.xsd">

    <!-- Request Mapping -->
    <request-map uri="createOrder">
        <!-- Security check -->
        <security https="true" auth="true"/>

        <!-- Call service before rendering view -->
        <event type="service" invoke="createOrder"/>

        <!-- Success response -->
        <response name="success" type="view" value="OrderCreated"/>

        <!-- Error response -->
        <response name="error" type="view" value="OrderEntry"/>
    </request-map>

    <!-- View Mapping -->
    <view-map name="OrderCreated" type="screen" page="component://order/widget/ordermgr/OrderScreens.xml#OrderCreated"/>

</site-conf>
```

### Request Flow Example

**URL**: `https://localhost:8443/accounting/control/createOrder`

1. **Routing**: Controller matches URI "createOrder"
2. **Security**: Checks if HTTPS and user authenticated
3. **Event**: Calls `createOrder` service
4. **Service Execution**: Service creates order in database
5. **Response**: Renders "OrderCreated" screen
6. **Output**: HTML page shown to user

### Event Types

| Type | Purpose | Example |
|------|---------|---------|
| `service` | Call OFBiz service | `<event type="service" invoke="createOrder"/>` |
| `java` | Call Java class method | `<event type="java" path="com.example.MyClass" invoke="myMethod"/>` |
| `simple` | Call simple method (XML-defined) | `<event type="simple" path="component://order/minilang/order/OrderServices.xml" invoke="createOrder"/>` |
| `groovy` | Call Groovy script | `<event type="groovy" path="component://order/groovyScripts/createOrder.groovy"/>` |

### Response Types

| Type | Purpose |
|------|---------|
| `view` | Render a screen |
| `request` | Forward to another request |
| `request-redirect` | HTTP redirect to another request |
| `url` | Redirect to external URL |
| `none` | No response (e.g., AJAX) |

---

## 3. Entity Engine

### Purpose
Object-Relational Mapping (ORM) layer that abstracts database operations.

### Key Features
- **Database Independence**: Works with PostgreSQL, MySQL, Oracle, etc.
- **Entity Definitions**: XML-based data model
- **Automatic Schema Generation**: Creates tables from entity definitions
- **Relationship Management**: Handles foreign keys and joins
- **Transaction Management**: ACID compliance
- **Caching**: Multi-level caching for performance

### Entity Definition

**File**: `entitydef/entitymodel.xml`

```xml
<entity entity-name="OrderHeader"
        package-name="org.apache.ofbiz.order.order"
        title="Order Header">

    <!-- Fields -->
    <field name="orderId" type="id"></field>
    <field name="orderTypeId" type="id"></field>
    <field name="orderDate" type="date-time"></field>
    <field name="statusId" type="id"></field>
    <field name="grandTotal" type="currency-amount"></field>
    <field name="billingPartyId" type="id"></field>

    <!-- Primary Key -->
    <prim-key field="orderId"/>

    <!-- Relationships -->
    <relation type="one" rel-entity-name="OrderType">
        <key-map field-name="orderTypeId"/>
    </relation>

    <relation type="one" rel-entity-name="StatusItem">
        <key-map field-name="statusId"/>
    </relation>

    <relation type="many" rel-entity-name="OrderItem">
        <key-map field-name="orderId"/>
    </relation>

    <relation type="one" rel-entity-name="Party" title="Billing">
        <key-map field-name="billingPartyId" rel-field-name="partyId"/>
    </relation>

    <!-- Indexes -->
    <index name="ORDER_DATE_IDX">
        <index-field name="orderDate"/>
    </index>
</entity>
```

### Entity Operations (Java/Groovy)

#### Using EntityQuery (Modern, Recommended)

```groovy
import org.apache.ofbiz.entity.util.EntityQuery

// Find one
def order = EntityQuery.use(delegator)
    .from("OrderHeader")
    .where("orderId", "SO-2025-001")
    .queryOne()

// Find list with conditions
def orders = EntityQuery.use(delegator)
    .from("OrderHeader")
    .where("orderTypeId", "SALES_ORDER",
           "statusId", "ORDER_APPROVED")
    .orderBy("orderDate DESC")
    .queryList()

// Find with filtering by date
def activeOrders = EntityQuery.use(delegator)
    .from("OrderHeader")
    .where("orderTypeId", "SALES_ORDER")
    .filterByDate()
    .queryList()

// Count
def orderCount = EntityQuery.use(delegator)
    .from("OrderHeader")
    .where("orderTypeId", "SALES_ORDER")
    .queryCount()

// Find with pagination
def pagedOrders = EntityQuery.use(delegator)
    .from("OrderHeader")
    .maxRows(20)
    .offset(40)
    .queryList()
```

#### CRUD Operations

```groovy
// Create
def newOrder = delegator.makeValue("OrderHeader", [
    orderId: "SO-2025-100",
    orderTypeId: "SALES_ORDER",
    orderDate: UtilDateTime.nowTimestamp(),
    statusId: "ORDER_CREATED",
    grandTotal: 15000.00,
    currencyUom: "USD"
])
newOrder.create()

// Read
def order = delegator.findOne("OrderHeader", [orderId: "SO-2025-100"], false)

// Update
order.statusId = "ORDER_APPROVED"
order.store()

// Delete
order.remove()
```

#### Relationships

```groovy
// Get related entities
def order = EntityQuery.use(delegator)
    .from("OrderHeader")
    .where("orderId", "SO-2025-001")
    .queryOne()

// Get order items (one-to-many)
def orderItems = order.getRelated("OrderItem", null, null, false)

// Get customer (many-to-one)
def customer = order.getRelatedOne("BillingParty", false)

// Get status (many-to-one)
def status = order.getRelatedOne("StatusItem", false)
```

### Entity Configuration

**File**: `framework/entity/config/entityengine.xml`

```xml
<entity-config>
    <!-- Delegator configuration -->
    <delegator name="default"
               entity-model-reader="main"
               entity-group-reader="main">
        <group-map group-name="org.apache.ofbiz"
                   datasource-name="localpostgres"/>
    </delegator>

    <!-- PostgreSQL datasource -->
    <datasource name="localpostgres"
                helper-class="org.apache.ofbiz.entity.datasource.GenericHelperDAO"
                field-type-name="postgres"
                check-on-start="true"
                add-missing-on-start="true">

        <read-data reader-name="seed"/>
        <read-data reader-name="seed-initial"/>
        <read-data reader-name="demo"/>
        <read-data reader-name="ext"/>

        <inline-jdbc
                jdbc-driver="org.postgresql.Driver"
                jdbc-uri="jdbc:postgresql://127.0.0.1/ftmerp"
                jdbc-username="ftmuser"
                jdbc-password="your_password"
                isolation-level="ReadCommitted"
                pool-minsize="2"
                pool-maxsize="250"/>
    </datasource>
</entity-config>
```

---

## 4. Service Engine

### Purpose
Manages business logic execution with transaction control, security, and async capabilities.

### Service Definition

**File**: `servicedef/services.xml`

```xml
<service name="createOrder" engine="groovy"
         location="component://order/groovyScripts/order/CreateOrder.groovy"
         auth="true">

    <description>Create a new order</description>

    <!-- Input Parameters -->
    <attribute name="orderTypeId" type="String" mode="IN" optional="false">
        <description>Order type (SALES_ORDER or PURCHASE_ORDER)</description>
    </attribute>

    <attribute name="partyId" type="String" mode="IN" optional="false">
        <description>Customer or supplier party ID</description>
    </attribute>

    <attribute name="orderItems" type="List" mode="IN" optional="false">
        <description>List of order items</description>
    </attribute>

    <!-- Output Parameters -->
    <attribute name="orderId" type="String" mode="OUT" optional="false">
        <description>Created order ID</description>
    </attribute>

    <attribute name="grandTotal" type="BigDecimal" mode="OUT">
        <description>Order grand total</description>
    </attribute>
</service>
```

### Service Engine Types

| Engine | Purpose | File Type |
|--------|---------|-----------|
| `groovy` | Groovy scripts | `.groovy` |
| `java` | Java classes | `.java` |
| `simple` | Simple method (XML DSL) | `.xml` |
| `entity-auto` | Auto CRUD operations | N/A (auto-generated) |
| `route` | Service routing/orchestration | `.xml` |

### Calling Services

#### From Groovy/Java

```groovy
import org.apache.ofbiz.service.ServiceUtil

def dispatcher = dctx.getDispatcher()

// Prepare context
def serviceCtx = [
    orderTypeId: "SALES_ORDER",
    partyId: "CUSTOMER-001",
    orderItems: [
        [productId: "FTM-SHIRT-001", quantity: 100],
        [productId: "FTM-PANT-001", quantity: 50]
    ],
    userLogin: userLogin
]

// Synchronous call
def result = dispatcher.runSync("createOrder", serviceCtx)

// Check result
if (ServiceUtil.isSuccess(result)) {
    def orderId = result.orderId
    def grandTotal = result.grandTotal
    Debug.log("Order created: ${orderId}, Total: ${grandTotal}")
} else {
    def errorMessage = ServiceUtil.getErrorMessage(result)
    Debug.logError("Failed: ${errorMessage}")
}
```

#### Asynchronous Services

```groovy
// Run in background
dispatcher.runAsync("sendOrderConfirmationEmail", serviceCtx)

// Schedule for later
def startTime = UtilDateTime.addDaysToTimestamp(UtilDateTime.nowTimestamp(), 1)
dispatcher.schedule("processRecurringOrder", serviceCtx, startTime, null, 0, 0, 1)
```

### Service Features

1. **Transaction Management**: Automatic transaction handling
2. **Security**: Built-in authentication and authorization
3. **Input Validation**: Type checking and required field validation
4. **Error Handling**: Standardized error responses
5. **Logging**: Automatic service call logging
6. **Caching**: Service result caching
7. **Async Execution**: Background job processing
8. **Scheduling**: Cron-like job scheduling

### Service ECA (Event Condition Action)

**File**: `servicedef/secas.xml`

```xml
<service-eca>
    <!-- Trigger when order is approved -->
    <eca service="changeOrderStatus" event="commit">
        <condition field-name="statusId" operator="equals" value="ORDER_APPROVED"/>
        <action service="createAutoRequirementsForOrder" mode="sync"/>
        <action service="sendOrderConfirmationEmail" mode="async"/>
    </eca>
</service-eca>
```

---

## 5. Widget System

### Purpose
Declarative UI framework for rendering screens, forms, menus, and trees.

### Widget Types

1. **Screen Widget**: Page layout and structure
2. **Form Widget**: Data entry and display forms
3. **Menu Widget**: Navigation menus
4. **Tree Widget**: Hierarchical data display

### Screen Widget

**File**: `widget/[Component]Screens.xml`

```xml
<screen name="OrderList">
    <!-- Actions (prepare data) -->
    <section>
        <actions>
            <service service-name="getOrderList" result-map="orderListResult"/>
            <set field="orders" from-field="orderListResult.orderList"/>
        </actions>

        <!-- Widgets (display) -->
        <widgets>
            <decorator-screen name="CommonDecorator" location="${parameters.mainDecoratorLocation}">
                <decorator-section name="body">
                    <!-- Page header -->
                    <container style="screenlet">
                        <container style="screenlet-title-bar">
                            <label text="Order List"/>
                        </container>

                        <!-- Include form -->
                        <include-form name="OrderListForm" location="component://order/widget/ordermgr/OrderForms.xml"/>
                    </container>
                </decorator-section>
            </decorator-screen>
        </widgets>
    </section>
</screen>
```

### Form Widget

**File**: `widget/[Component]Forms.xml`

```xml
<form name="OrderListForm" type="list" list-name="orders">
    <!-- Field definitions -->
    <field name="orderId">
        <display-entity entity-name="OrderHeader" description="${orderId}"/>
    </field>

    <field name="orderDate">
        <display type="date"/>
    </field>

    <field name="statusId">
        <display-entity entity-name="StatusItem" description="${description}"/>
    </field>

    <field name="grandTotal">
        <display type="currency" currency="${currencyUom}"/>
    </field>

    <field name="actions">
        <hyperlink target="ViewOrder" description="View">
            <parameter param-name="orderId"/>
        </hyperlink>
    </field>
</form>
```

### Menu Widget

**File**: `widget/[Component]Menus.xml`

```xml
<menu name="OrderMainMenu" type="simple">
    <menu-item name="CreateOrder">
        <link target="CreateOrder"/>
        <label text="Create Order"/>
    </menu-item>

    <menu-item name="FindOrders">
        <link target="FindOrders"/>
        <label text="Find Orders"/>
    </menu-item>

    <menu-item name="Reports">
        <label text="Reports"/>
        <sub-menu>
            <menu-item name="SalesReport">
                <link target="SalesReport"/>
                <label text="Sales Report"/>
            </menu-item>
        </sub-menu>
    </menu-item>
</menu>
```

---

## System Integration

### How Systems Work Together

```
User Request (HTTP)
     ↓
[1. Web Server] Tomcat receives request
     ↓
[2. MVC Framework] Controller routes to handler
     ↓
[4. Service Engine] Calls business logic service
     ↓
[3. Entity Engine] Queries/updates database
     ↓
[4. Service Engine] Returns result
     ↓
[5. Widget System] Renders screen/form
     ↓
[2. MVC Framework] Generates HTTP response
     ↓
[1. Web Server] Sends response to user
```

### Example: Complete Request Flow

**User Action**: Click "Create Order" button

1. **Tomcat** (Web Server): Receives POST request
2. **Controller** (MVC): Matches URI "createOrder"
3. **Security Check**: Verifies user authenticated and authorized
4. **Event Handler**: Calls `createOrder` service
5. **Service Engine**: Executes service logic
6. **Entity Engine**: Creates OrderHeader and OrderItem entities
7. **Service ECA**: Triggers `sendOrderConfirmationEmail` service
8. **Service Engine**: Returns result with orderId
9. **Widget System**: Renders "OrderCreated" screen
10. **Controller**: Returns view response
11. **Tomcat**: Sends HTML to browser

---

## Configuration Files Reference

| System | Configuration File | Purpose |
|--------|-------------------|---------|
| Web Server | `framework/catalina/ofbiz-component.xml` | Tomcat configuration |
| MVC Framework | `webapp/*/WEB-INF/controller.xml` | Request routing |
| Entity Engine | `framework/entity/config/entityengine.xml` | Database configuration |
| Entity Engine | `*/entitydef/entitymodel.xml` | Entity definitions |
| Service Engine | `*/servicedef/services.xml` | Service definitions |
| Service Engine | `*/servicedef/secas.xml` | Service triggers |
| Widget System | `*/widget/*Screens.xml` | Screen definitions |
| Widget System | `*/widget/*Forms.xml` | Form definitions |
| Widget System | `*/widget/*Menus.xml` | Menu definitions |

---

## Best Practices

### Entity Engine
- ✅ Use `EntityQuery` (modern) instead of `EntityUtil` (deprecated)
- ✅ Always use `filterByDate()` for time-dependent data
- ✅ Enable caching for frequently accessed entities
- ✅ Use database-specific field types (via `field-type-name`)
- ✅ Index foreign keys and frequently queried fields

### Service Engine
- ✅ Keep services focused (single responsibility)
- ✅ Always validate input parameters
- ✅ Return standardized success/error responses
- ✅ Use transactions appropriately
- ✅ Document service purpose and parameters
- ✅ Use async services for non-critical operations

### Widget System
- ✅ Separate data preparation (actions) from display (widgets)
- ✅ Reuse common decorators
- ✅ Use include-screen/include-form for modularity
- ✅ Keep forms simple and focused
- ✅ Use proper widget types (list, single, multi)

### MVC Framework
- ✅ Keep controllers thin (delegate to services)
- ✅ Use semantic URIs
- ✅ Implement proper security checks
- ✅ Handle errors gracefully
- ✅ Use request-redirect after POST (PRG pattern)

---

## Troubleshooting

### Common Issues

**Entity Engine**:
- Foreign key violations → Check relationships and data
- Column not found → Check entity definition vs database schema
- Slow queries → Add indexes, check cache settings

**Service Engine**:
- Required parameter missing → Check service definition
- Transaction timeout → Increase timeout or make service async
- Permission denied → Check security settings

**Widget System**:
- Screen not rendering → Check decorator chain
- Form validation errors → Review field validators
- Missing data → Check actions section

**MVC Framework**:
- 404 errors → Check controller.xml URI mapping
- 403 forbidden → Check security settings
- Infinite redirects → Check response chains

---

## Additional Resources

- **Developer Manual**: https://ofbizextra.org/ofbiz_adocs/docs/asciidoc/developer-manual.pdf
- **API JavaDoc**: https://nightlies.apache.org/ofbiz/trunk/javadocs/
- **User Manual**: https://nightlies.apache.org/ofbiz/trunk/ofbiz/html5/user-manual.html
- **Data Model**: https://nightlies.apache.org/ofbiz/trunk/ofbiz/html5/data-model.html
- **Wiki**: https://cwiki.apache.org/confluence/display/OFBIZ

---

**Document Version**: 1.0
**Last Updated**: 2025-12-18
**Reference**: Apache OFBiz Developer Manual
