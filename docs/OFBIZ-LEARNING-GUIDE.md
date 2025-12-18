# Apache OFBiz Learning Guide for FTM IT Team

A practical guide to understanding and operating the FTM Garments ERP system built on Apache OFBiz.

---

## Table of Contents

1. [Introduction](#introduction)
2. [OFBiz Architecture Overview](#ofbiz-architecture-overview)
3. [Understanding the Data Model](#understanding-the-data-model)
4. [Service Engine - The Heart of OFBiz](#service-engine)
5. [Business Workflows Explained](#business-workflows-explained)
6. [Common Operations](#common-operations)
7. [Troubleshooting Guide](#troubleshooting-guide)
8. [Development Basics](#development-basics)

---

## Introduction

### What is Apache OFBiz?

Apache OFBiz (Open For Business) is an open-source Enterprise Resource Planning (ERP) system built on Java. It's a comprehensive framework that provides:

- **Order Management** - Sales and purchase orders
- **Manufacturing** - Production planning and execution
- **Inventory Management** - Stock tracking and warehouse operations
- **Accounting** - General ledger, invoicing, payments
- **Human Resources** - Employee and payroll management
- **E-commerce** - Online store capabilities

### Why OFBiz is Different

Unlike traditional ERPs where you click through screens:

**OFBiz is:**
- **Service-oriented**: Operations are performed by calling services
- **Entity-based**: Data is stored in entities (think database tables, but better)
- **Event-driven**: Actions trigger other actions automatically
- **Highly customizable**: We can modify almost everything for FTM Garments

### Key Concept: Think in Terms of Entities and Services

```
Entity = Data (what you store)
Service = Logic (what you do with data)
Screen = UI (what you see)
```

**Example for Garments:**
- **Entity**: OrderHeader (stores order information)
- **Service**: createOrder (creates a new order)
- **Screen**: Order Entry Form (web page to enter order)

---

## OFBiz Architecture Overview

### The Four Layers

```
┌────────────────────────────────────┐
│   USER INTERFACE (Web Pages)      │ ← What users see
├────────────────────────────────────┤
│   SERVICES (Business Logic)       │ ← What happens when you click
├────────────────────────────────────┤
│   ENTITIES (Data Model)            │ ← Where data is stored
├────────────────────────────────────┤
│   DATABASE (PostgreSQL)            │ ← Physical storage
└────────────────────────────────────┘
```

### Directory Structure

```
/home/user/ftmerp-java-project/
├── applications/          # Business modules
│   ├── order/            # Order management
│   ├── manufacturing/    # Production
│   ├── product/          # Products & inventory
│   ├── accounting/       # Financial
│   └── ...
├── framework/            # Core framework
│   ├── entity/          # Database layer
│   ├── service/         # Service engine
│   └── widget/          # UI components
├── plugins/             # Custom plugins (symlink to ofbiz-plugins)
│   └── ftm-garments/    # Our FTM customizations
├── runtime/             # Running system
│   ├── data/           # Database files (if using embedded DB)
│   ├── logs/           # Log files (important!)
│   └── temp/           # Temporary files
└── build.gradle        # Build configuration
```

---

## Understanding the Data Model

### What is an Entity?

An **Entity** is like a database table, but with extra intelligence. It knows:
- What fields it has
- How it relates to other entities
- Validation rules

**Example: OrderHeader Entity**

```xml
<entity entity-name="OrderHeader">
    <field name="orderId" type="id"></field>              <!-- Unique ID -->
    <field name="orderTypeId" type="id"></field>          <!-- SALES or PURCHASE -->
    <field name="orderDate" type="date-time"></field>     <!-- When created -->
    <field name="statusId" type="id"></field>             <!-- Current status -->
    <field name="grandTotal" type="currency-amount"></field>
    <field name="billingPartyId" type="id"></field>       <!-- Customer -->

    <prim-key field="orderId"/>                           <!-- Primary key -->

    <relation type="many" rel-entity-name="OrderItem">   <!-- Has many items -->
        <key-map field-name="orderId"/>
    </relation>
    <relation type="one" rel-entity-name="Party" fk-name="billingPartyId">
        <key-map field-name="billingPartyId" rel-field-name="partyId"/>
    </relation>
</entity>
```

### How Entities Relate: The Order Example

```
OrderHeader (1 order)
  ├─ has many → OrderItem (products in the order)
  ├─ belongs to → Party (customer)
  └─ has many → OrderShipment (shipments)
      └─ has one → Shipment
```

**In Plain English:**
- One **OrderHeader** contains multiple **OrderItem** records (like line items on an invoice)
- Each **OrderHeader** belongs to a **Party** (customer)
- Orders can have multiple **Shipments** (partial shipments)

### Field Types You'll See Often

| Type | Description | Example |
|------|-------------|---------|
| `id` | Unique identifier | `SO-2025-001` |
| `id-ne` | Non-empty ID | `SALES_ORDER` |
| `date-time` | Date and time | `2025-01-15 10:30:00` |
| `currency-amount` | Money | `15000.00` |
| `fixed-point` | Decimal number | `123.45` |
| `indicator` | Yes/No (Y/N) | `Y` or `N` |
| `description` | Short text | Up to 255 chars |
| `very-long` | Long text | Unlimited |

### Finding Entity Definitions

All entity definitions are in XML files under `/applications/datamodel/entitydef/`:

```bash
cd /home/user/ftmerp-java-project/applications/datamodel/entitydef

# Search for an entity
grep -r "entity-name=\"OrderHeader\"" .

# View entity definition
less order-entitymodel.xml
```

**Pro Tip**: Use `Ctrl+F` in your text editor to search for entity names.

---

## Service Engine - The Heart of OFBiz

### What is a Service?

A **Service** is a piece of business logic that performs an action. Think of it as a function or method.

**Example Services:**
- `createOrder` - Creates a new sales order
- `updateInventory` - Updates stock quantity
- `shipOrder` - Ships an order to customer

### Service Anatomy

```xml
<service name="createOrder" engine="simple">
    <description>Create a sales order</description>

    <!-- What you need to provide -->
    <attribute name="orderTypeId" type="String" mode="IN" optional="false"/>
    <attribute name="productId" type="String" mode="IN"/>
    <attribute name="quantity" type="BigDecimal" mode="IN"/>

    <!-- What you get back -->
    <attribute name="orderId" type="String" mode="OUT"/>
</service>
```

**Breaking it down:**
- **name**: Service identifier
- **engine**: How it runs (simple, java, groovy, etc.)
- **attribute mode="IN"**: Input parameter (you must provide)
- **attribute mode="OUT"**: Output parameter (service returns)
- **optional="false"**: Required parameter

### Calling a Service

#### From Web UI:
1. User clicks "Create Order" button
2. Form data is submitted
3. OFBiz calls the `createOrder` service
4. Service processes data
5. Result shown to user

#### From Command Line (Webtools):

```
1. Open browser: https://localhost:8443/webtools
2. Login (admin/ofbiz)
3. Go to: Service Engine → Service List
4. Search for service name
5. Click "Schedule Job" or "Run Sync"
6. Fill in parameters
7. Submit
```

#### From Code (Groovy):

```groovy
def dispatcher = dctx.getDispatcher()

// Prepare input parameters
def serviceCtx = [
    orderTypeId: "SALES_ORDER",
    productId: "FTM-SHIRT-BLUE-M",
    quantity: 100,
    userLogin: userLogin
]

// Call service
def result = dispatcher.runSync("createOrder", serviceCtx)

// Check result
if (ServiceUtil.isSuccess(result)) {
    def orderId = result.orderId
    Debug.log("Order created: ${orderId}")
} else {
    Debug.logError("Failed: ${result.errorMessage}")
}
```

### Finding Service Definitions

Services are defined in `servicedef/` directories:

```bash
cd /home/user/ftmerp-java-project/applications

# Find all service definition files
find . -name "services*.xml" -type f

# Search for a specific service
grep -r "service name=\"createOrder\"" .

# View services in order module
less order/servicedef/services.xml
```

---

## Business Workflows Explained

### Workflow 1: Sales Order to Delivery

This is the complete process from when a customer orders to when they receive the goods.

#### Step-by-Step Process

```
[Customer Places Order]
         ↓
    Order Created → OrderHeader entity created
         ↓
    Order Approved → Status changes to APPROVED
         ↓
    MRP Runs → Checks if we have materials
         ↓
    Production Run Created → WorkEffort entity created
         ↓
    Materials Issued → Inventory reduced
         ↓
    Production Tasks → Cutting, Sewing, QC, Packing
         ↓
    Finished Goods Received → Inventory increased
         ↓
    Shipment Created → Shipment entity created
         ↓
    Items Packed → ShipmentPackage entities
         ↓
    Shipped → Status changed to SHIPPED
         ↓
    [Customer Receives Goods]
```

#### The Entities Involved

| Step | Primary Entity | Status Field |
|------|---------------|--------------|
| Order Creation | `OrderHeader` | `ORDER_CREATED` |
| Order Approval | `OrderHeader` | `ORDER_APPROVED` |
| Production Planning | `MrpEvent` | - |
| Production Creation | `WorkEffort` | `PRUN_CREATED` |
| Production Running | `WorkEffort` | `PRUN_RUNNING` |
| Production Complete | `WorkEffort` | `PRUN_COMPLETED` |
| Shipment Created | `Shipment` | `SHIPMENT_INPUT` |
| Shipped | `Shipment` | `SHIPMENT_SHIPPED` |
| Delivered | `Shipment` | `SHIPMENT_DELIVERED` |

#### Key Services for This Workflow

| Action | Service Name | Input | Output |
|--------|-------------|-------|--------|
| Create Order | `createOrderFromShoppingCart` | cart, party | orderId |
| Approve Order | `changeOrderStatus` | orderId, statusId | - |
| Run MRP | `executeMrp` | facilityId | mrpEvents |
| Create Production | `createProductionRun` | productId, quantity | productionRunId |
| Issue Materials | `issueInventoryItemToWorkEffort` | workEffortId, productId | - |
| Complete Task | `changeProductionRunTaskStatus` | workEffortId, statusId | - |
| Create Shipment | `createShipment` | orderId | shipmentId |
| Ship Order | `quickShipEntireOrder` | orderId, shipmentId | - |

### Workflow 2: Purchase Order (Buying Raw Materials)

```
[Need Materials]
         ↓
    Create Requirement → Requirement entity
         ↓
    Assign Supplier → SupplierProduct lookup
         ↓
    Create Purchase Order → OrderHeader (type=PURCHASE)
         ↓
    Send to Supplier → (external)
         ↓
    Receive Goods → InventoryItem updated
         ↓
    [Materials in Stock]
```

### Workflow 3: Inventory Movement

```
[Purchase Received]
         ↓
    Receive Inventory → InventoryItem created/updated
         ↓
    Put Away → Location assigned
         ↓
[Production Needs Material]
         ↓
    Issue to Work Order → Inventory reduced
         ↓
    Production Consumes → (manufacturing)
         ↓
[Production Complete]
         ↓
    Receive Finished Goods → InventoryItem increased
         ↓
[Customer Order Ships]
         ↓
    Ship Inventory → Inventory reduced
```

---

## Common Operations

### Operation 1: Check Order Status

**Web UI Method:**
```
1. Navigate to: Accounting → Orders
2. Search by Order ID or Customer
3. Click order number
4. View status on order detail page
```

**Database Method:**
```sql
SELECT
    oh.order_id,
    oh.order_date,
    oh.status_id,
    s.description as status_name,
    oh.grand_total
FROM order_header oh
JOIN status_item s ON oh.status_id = s.status_id
WHERE oh.order_id = 'SO-2025-001';
```

**Command Line:**
```bash
# Connect to PostgreSQL
psql -U ftmuser -d ftmerp

# Run query
SELECT * FROM order_header WHERE order_id = 'SO-2025-001';
```

### Operation 2: Check Inventory

**Web UI:**
```
1. Navigate to: Catalog → Inventory
2. Search by Product ID
3. View quantity on hand and available to promise
```

**Database:**
```sql
SELECT
    ii.product_id,
    p.internal_name,
    ii.facility_id,
    ii.location_seq_id,
    ii.quantity_on_hand_total,
    ii.available_to_promise_total
FROM inventory_item ii
JOIN product p ON ii.product_id = p.product_id
WHERE ii.product_id = 'FTM-SHIRT-BLUE-M'
AND ii.facility_id = 'FTM-FAC-MAIN';
```

### Operation 3: View Production Run Status

**Web UI:**
```
1. Navigate to: Manufacturing → Production Run
2. Search by Production Run ID
3. View tasks and status
```

**Database:**
```sql
SELECT
    we.work_effort_id,
    we.work_effort_name,
    we.current_status_id,
    we.quantity_to_produce,
    we.quantity_produced,
    we.estimated_start_date,
    we.estimated_completion_date,
    we.actual_completion_date
FROM work_effort we
WHERE we.work_effort_type_id = 'PROD_ORDER_HEADER'
AND we.work_effort_id LIKE 'PR-%';
```

### Operation 4: Create a Sales Order (Simplified)

**Steps:**
1. Go to: Accounting → Orders → Create New Order
2. Select order type: Sales Order
3. Select customer
4. Add product line items:
   - Product ID: FTM-SHIRT-BLUE-M
   - Quantity: 100
   - Price: 30.00
5. Set shipping information
6. Submit order
7. Approve order (change status to APPROVED)

**Behind the scenes:**
- `OrderHeader` entity created
- `OrderItem` entities created for each product
- `OrderItemShipGroup` created for shipping
- Services called: `createOrderFromShoppingCart`, `storeOrder`

### Operation 5: Run MRP

**When to run:**
- Daily (automated)
- After receiving new orders
- When planning production for next week

**How to run:**
```
1. Navigate to: Manufacturing → MRP
2. Click "Run MRP"
3. Select facility: FTM-FAC-MAIN
4. Select MRP name: "Daily MRP Run"
5. Submit

System will:
- Analyze all pending orders
- Check current inventory
- Calculate material requirements
- Create MrpEvent records
- Suggest production runs or purchase orders
```

**View MRP Results:**
```sql
SELECT
    me.product_id,
    p.internal_name,
    me.mrp_event_type_id,
    me.quantity,
    me.event_date,
    me.is_late
FROM mrp_event me
JOIN product p ON me.product_id = p.product_id
ORDER BY me.event_date;
```

---

## Troubleshooting Guide

### Issue 1: "Service Error: Required parameter missing"

**Problem:** Called a service without providing required input.

**Example Error:**
```
Service [createOrder] missing required IN parameter [orderTypeId]
```

**Solution:**
1. Check service definition for required parameters
2. Ensure all `optional="false"` parameters are provided
3. Check parameter spelling (case-sensitive!)

**Fix:**
```groovy
// Bad
def result = dispatcher.runSync("createOrder", [
    productId: "FTM-SHIRT-BLUE-M"
])

// Good
def result = dispatcher.runSync("createOrder", [
    orderTypeId: "SALES_ORDER",  // ← Was missing
    productId: "FTM-SHIRT-BLUE-M",
    userLogin: userLogin          // ← Usually required
])
```

### Issue 2: "Entity not found"

**Problem:** Trying to access a record that doesn't exist.

**Example Error:**
```
Entity not found for primaryKey: [orderId:SO-INVALID]
```

**Solution:**
1. Verify the ID exists in database
2. Check for typos in ID
3. Ensure transaction was committed

**Check:**
```sql
SELECT * FROM order_header WHERE order_id = 'SO-INVALID';
-- Returns no rows = doesn't exist
```

### Issue 3: Order Status Won't Change

**Problem:** Trying to change order status but it fails.

**Reason:** OFBiz has status validation rules. You can't jump from `ORDER_CREATED` directly to `ORDER_COMPLETED`.

**Valid Status Flow:**
```
ORDER_CREATED
  → ORDER_APPROVED
  → ORDER_SENT
  → ORDER_COMPLETED
```

**Fix:**
Change status step by step following the allowed flow.

### Issue 4: Inventory Shows Zero But Should Have Stock

**Problem:** Inventory shows 0 even after receiving goods.

**Common Causes:**
1. Wrong facility ID
2. Wrong location
3. Transaction not committed
4. Inventory in different UOM (units of measure)

**Troubleshooting:**
```sql
-- Check all inventory for product across all facilities
SELECT
    facility_id,
    location_seq_id,
    quantity_on_hand_total,
    available_to_promise_total
FROM inventory_item
WHERE product_id = 'FTM-SHIRT-BLUE-M';

-- Check inventory history
SELECT
    effective_date,
    quantity_on_hand_diff,
    description
FROM inventory_item_detail
WHERE inventory_item_id = 'INV-001'
ORDER BY effective_date DESC;
```

### Issue 5: Production Run Not Starting

**Problem:** Created production run but tasks won't start.

**Checklist:**
1. ✓ Is production run status `PRUN_DOC_PRINTED` or `PRUN_CREATED`?
2. ✓ Are materials available?
3. ✓ Have materials been issued to the production run?
4. ✓ Are tasks in correct sequence?
5. ✓ Is facility/location configured?

**Fix:**
```
1. Change production run status to PRUN_DOC_PRINTED
2. Issue materials using issueInventoryItemToWorkEffort service
3. Change task status to PRUN_RUNNING
```

### Where to Look for Errors

#### 1. Log Files (Most Important!)

```bash
cd /home/user/ftmerp-java-project/runtime/logs

# View latest log
tail -f ofbiz.log

# Search for errors
grep -i "error" ofbiz.log | tail -20

# Search for specific service
grep "createOrder" ofbiz.log

# View specific time period
grep "2025-01-15 10:" ofbiz.log
```

**Log Entry Example:**
```
2025-01-15 10:30:45,123 |ERROR| ServiceDispatcher |
Error in Service [createOrder]:
org.apache.ofbiz.service.ServiceValidationException:
Missing required parameter: orderTypeId
```

#### 2. Web Tools Error Log

```
1. Open: https://localhost:8443/webtools
2. Go to: Logging → View Log
3. Filter by: ERROR or WARN
```

#### 3. Database Constraints

```bash
psql -U ftmuser -d ftmerp

# Check for constraint violations
SELECT * FROM pg_stat_activity WHERE state = 'idle in transaction (aborted)';
```

---

## Development Basics

### Creating a Custom Service

**File:** `/plugins/ftm-garments/servicedef/services.xml`

```xml
<service name="ftmCalculateGarmentCost" engine="groovy"
         location="component://ftm-garments/src/main/groovy/CalculateCost.groovy">
    <description>Calculate total cost for garment production</description>

    <attribute name="productId" type="String" mode="IN" optional="false"/>
    <attribute name="quantity" type="BigDecimal" mode="IN" optional="false"/>

    <attribute name="totalMaterialCost" type="BigDecimal" mode="OUT"/>
    <attribute name="totalLaborCost" type="BigDecimal" mode="OUT"/>
    <attribute name="totalCost" type="BigDecimal" mode="OUT"/>
</service>
```

**Implementation:** `/plugins/ftm-garments/src/main/groovy/CalculateCost.groovy`

```groovy
import org.apache.ofbiz.entity.util.EntityQuery

def productId = parameters.productId
def quantity = parameters.quantity

// Get BOM components
def bomComponents = EntityQuery.use(delegator)
    .from("ProductAssoc")
    .where("productId", productId,
           "productAssocTypeId", "MANUF_COMPONENT")
    .filterByDate()
    .queryList()

def materialCost = 0.0

// Calculate material cost
bomComponents.each { component ->
    def componentProduct = component.getRelatedOne("AssocProduct", false)
    def unitCost = componentProduct.getBigDecimal("defaultPrice") ?: 0.0
    def qtyNeeded = component.getBigDecimal("quantity") ?: 1.0
    def scrapFactor = component.getBigDecimal("scrapFactor") ?: 1.0

    materialCost += unitCost * qtyNeeded * scrapFactor * quantity
}

// Simplified labor cost (can be complex)
def laborCost = quantity * 5.00  // $5 labor per unit

def totalCost = materialCost + laborCost

// Return results
return [
    totalMaterialCost: materialCost,
    totalLaborCost: laborCost,
    totalCost: totalCost
]
```

### Creating a Custom Entity

**File:** `/plugins/ftm-garments/entitydef/entitymodel.xml`

```xml
<entity entity-name="FtmGarmentStyle" package-name="com.ftm.garments">
    <field name="styleId" type="id"></field>
    <field name="styleName" type="name"></field>
    <field name="description" type="description"></field>
    <field name="season" type="name"></field>
    <field name="year" type="numeric"></field>
    <field name="designer" type="name"></field>
    <field name="targetMarket" type="description"></field>
    <field name="fromDate" type="date-time"></field>
    <field name="thruDate" type="date-time"></field>

    <prim-key field="styleId"/>
</entity>
```

**Load Initial Data:** `/plugins/ftm-garments/data/FtmGarmentsData.xml`

```xml
<entity-engine-xml>
    <FtmGarmentStyle styleId="STYLE-CASUAL-001"
                     styleName="Casual Blue Shirt"
                     season="Spring/Summer"
                     year="2025"
                     designer="John Doe"
                     fromDate="2025-01-01 00:00:00"/>
</entity-engine-xml>
```

### Building and Deploying

```bash
cd /home/user/ftmerp-java-project

# Clean build
./gradlew cleanAll

# Build
./gradlew build

# Load your custom entity data
./gradlew "ofbiz --load-data readers=seed,seed-initial,ext,ftm-garments"

# Restart OFBiz
./gradlew ofbiz
```

---

## Best Practices for FTM Team

### 1. Always Check Logs First

When something doesn't work:
```bash
tail -f runtime/logs/ofbiz.log
```

### 2. Use Transactions Carefully

OFBiz services run in transactions. If one fails, all fail (rollback).

**Good:**
```groovy
// This is good - all succeeds or all fails
runService("createOrder")
runService("createShipment")
```

**Be Careful:**
```groovy
// If createShipment fails, order is still created
runService("createOrder")
// ... some other code ...
runService("createShipment")  // Might fail!
```

### 3. Test in DEV First

**Never test directly in production!**

Setup environments:
- **DEV** (rpitex): For development and testing
- **STAGE**: For user acceptance testing
- **PROD**: Live system

### 4. Backup Database Regularly

```bash
# Daily backup
pg_dump -U ftmuser -d ftmerp > ftmerp_backup_$(date +%Y%m%d).sql

# Keep 7 days of backups
find /backups -name "ftmerp_backup_*.sql" -mtime +7 -delete
```

### 5. Document Your Changes

When you modify FTM-specific code:
```
File: /plugins/ftm-garments/src/.../MyService.groovy
Date: 2025-01-15
Author: [Your Name]
Purpose: Calculate garment production cost
Changes: Added scrap factor calculation
```

---

## Quick Reference

### Essential URLs

| Purpose | URL |
|---------|-----|
| Main App | https://localhost:8443/accounting |
| Web Tools | https://localhost:8443/webtools |
| Entity Data Maintenance | https://localhost:8443/webtools/control/EntityDataMaintenance |
| Service List | https://localhost:8443/webtools/control/ServiceList |
| Job Scheduler | https://localhost:8443/webtools/control/JobList |

### Common Entity Names

| Business Concept | Entity Name |
|------------------|-------------|
| Sales Order | OrderHeader |
| Order Line Item | OrderItem |
| Customer | Party |
| Product | Product |
| Inventory | InventoryItem |
| Production Run | WorkEffort (type=PROD_ORDER_HEADER) |
| Shipment | Shipment |
| Purchase Order | OrderHeader (type=PURCHASE_ORDER) |
| Supplier | Party (role=SUPPLIER) |

### Common Service Names

| Action | Service Name |
|--------|-------------|
| Create Order | createOrderFromShoppingCart |
| Approve Order | changeOrderStatus |
| Create Shipment | createShipment |
| Ship Order | quickShipEntireOrder |
| Create Production Run | createProductionRun |
| Issue Inventory | issueInventoryItemToWorkEffort |
| Receive Inventory | receiveInventoryProduct |
| Run MRP | executeMrp |

### Common Status Codes

#### Order Status
- `ORDER_CREATED` - Just created
- `ORDER_APPROVED` - Ready to process
- `ORDER_SENT` - Sent to production/warehouse
- `ORDER_COMPLETED` - Delivered
- `ORDER_CANCELLED` - Cancelled

#### Production Run Status
- `PRUN_CREATED` - Created
- `PRUN_DOC_PRINTED` - Ready to start
- `PRUN_RUNNING` - In progress
- `PRUN_COMPLETED` - Finished
- `PRUN_CLOSED` - Closed

#### Shipment Status
- `SHIPMENT_INPUT` - Being prepared
- `SHIPMENT_PICKED` - Items picked from warehouse
- `SHIPMENT_PACKED` - Packed in boxes
- `SHIPMENT_SHIPPED` - Shipped to customer
- `SHIPMENT_DELIVERED` - Delivered

---

## Learning Path for New Team Members

### Week 1: Understand the Basics
- [ ] Read this guide completely
- [ ] Access OFBiz web interface
- [ ] Browse entities in Entity Data Maintenance
- [ ] View service definitions in Service List
- [ ] Check logs when performing actions

### Week 2: Practice Common Operations
- [ ] Create a test sales order
- [ ] Check inventory levels
- [ ] View a production run
- [ ] Create a test shipment
- [ ] Query database directly with psql

### Week 3: Understand Workflows
- [ ] Follow a sales order from creation to shipment
- [ ] Watch MRP process
- [ ] Understand BOM explosion
- [ ] Track inventory movements

### Week 4: Start Customizing
- [ ] Create a simple custom service
- [ ] Add a custom entity
- [ ] Load test data
- [ ] Write queries to extract data

---

## Getting Help

### Resources

1. **Official OFBiz Documentation**
   - https://ofbiz.apache.org/documentation.html
   - https://cwiki.apache.org/confluence/display/OFBIZ

2. **FTM Internal Documentation**
   - `/docs/FTM-SETUP-GUIDE.adoc` - Complete setup
   - `/docs/QUICK-START.md` - Quick reference
   - `/docs/FTM-GARMENTS-WORKFLOW-DATASET.md` - Sample data

3. **Community**
   - OFBiz User Mailing List: user@ofbiz.apache.org
   - OFBiz Wiki: https://cwiki.apache.org/confluence/display/OFBIZ

4. **Code Analysis**
   - Use vim/tmux with LLM assistance (see LLM setup guide)
   - Use grep to search codebase
   - Read source code in `/applications`

### Internal Contacts

- **System Administrator**: [Setup PostgreSQL, infrastructure]
- **Lead Developer**: [OFBiz customization, complex issues]
- **Business Analyst**: [Workflow questions, requirements]

---

## Summary

**Remember:**
1. **Entity** = Data structure
2. **Service** = Business logic
3. **Screen** = User interface
4. **Status** = Current state of a record
5. **Workflow** = Series of services that accomplish a business goal

**When stuck:**
1. Check logs (`runtime/logs/ofbiz.log`)
2. Verify entity data in database
3. Check service definition for required parameters
4. Review status flow
5. Ask for help with specific error messages

**Best approach:**
- Start small (understand one workflow at a time)
- Practice in DEV environment
- Use LLM assistance for code explanation
- Document what you learn

---

**Document Version**: 1.0
**Last Updated**: 2025-12-18
**Target Audience**: FTM IT Team
**Difficulty**: Beginner to Intermediate
