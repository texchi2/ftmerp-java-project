# FTM Garments ERP Workflow Dataset

Complete end-to-end workflow dataset for garment manufacturing business operations using Apache OFBiz.

---

## Table of Contents

1. [Business Scenario](#business-scenario)
2. [Master Data Setup](#master-data-setup)
3. [Workflow: Sales Order to Delivery](#workflow-sales-order-to-delivery)
4. [Entity Data Examples](#entity-data-examples)
5. [Service Call Sequences](#service-call-sequences)
6. [Integration Points](#integration-points)

---

## Business Scenario

**Company**: FTM Garments Manufacturing
**Customer**: ABC Retail Store
**Order**: 500 units of Men's Blue Casual Shirt (Size M)
**Delivery Date**: 2025-02-28
**Order Value**: $15,000 USD

---

## Master Data Setup

### 1. Product Catalog

#### **Finished Goods**

```xml
<!-- Men's Casual Shirt - Blue, Size M -->
<Product productId="FTM-SHIRT-BLUE-M" productTypeId="FINISHED_GOOD">
    <internalName>Men's Casual Shirt Blue Medium</internalName>
    <primaryProductCategoryId>CASUAL_SHIRTS</primaryProductCategoryId>
    <quantityUomId>ea</quantityUomId> <!-- each -->
    <defaultPrice>30.00</defaultPrice>
    <currencyUomId>USD</currencyUomId>
    <weight>0.25</weight>
    <weightUomId>kg</weightUomId>
</Product>

<!-- Product Features -->
<ProductFeature productFeatureId="COLOR_BLUE" productFeatureTypeId="COLOR">
    <description>Blue</description>
</ProductFeature>

<ProductFeature productFeatureId="SIZE_M" productFeatureTypeId="SIZE">
    <description>Medium</description>
</ProductFeature>

<ProductFeatureAppl productId="FTM-SHIRT-BLUE-M" productFeatureId="COLOR_BLUE" fromDate="2025-01-01"/>
<ProductFeatureAppl productId="FTM-SHIRT-BLUE-M" productFeatureId="SIZE_M" fromDate="2025-01-01"/>
```

#### **Raw Materials**

```xml
<!-- Cotton Fabric - Blue, 45" width -->
<Product productId="FTM-FABRIC-COTTON-BLUE-45" productTypeId="RAW_MATERIAL">
    <internalName>Cotton Fabric Blue 45 inch</internalName>
    <quantityUomId>m</quantityUomId> <!-- meter -->
    <defaultPrice>5.50</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- White Plastic Buttons 20mm -->
<Product productId="FTM-BTN-WHITE-20MM" productTypeId="RAW_MATERIAL">
    <internalName>White Plastic Button 20mm</internalName>
    <quantityUomId>ea</quantityUomId>
    <defaultPrice>0.05</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Metal Zipper 50cm -->
<Product productId="FTM-ZIP-METAL-50CM" productTypeId="RAW_MATERIAL">
    <internalName>Metal Zipper 50cm</internalName>
    <quantityUomId>ea</quantityUomId>
    <defaultPrice>0.80</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Care Label -->
<Product productId="FTM-LABEL-CARE-EN" productTypeId="RAW_MATERIAL">
    <internalName>Care Label English</internalName>
    <quantityUomId>ea</quantityUomId>
    <defaultPrice>0.02</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Thread -->
<Product productId="FTM-THREAD-BLUE" productTypeId="RAW_MATERIAL">
    <internalName>Sewing Thread Blue</internalName>
    <quantityUomId>m</quantityUomId>
    <defaultPrice>0.01</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>
```

### 2. Bill of Materials (BOM)

```xml
<!-- BOM for FTM-SHIRT-BLUE-M -->

<!-- Fabric component -->
<ProductAssoc
    productId="FTM-SHIRT-BLUE-M"
    productIdTo="FTM-FABRIC-COTTON-BLUE-45"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01"
    quantity="1.5"
    quantityUomId="m"
    scrapFactor="1.20"
    sequenceNum="10"
    instruction="Cut according to pattern">
</ProductAssoc>

<!-- Buttons -->
<ProductAssoc
    productId="FTM-SHIRT-BLUE-M"
    productIdTo="FTM-BTN-WHITE-20MM"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01"
    quantity="6"
    quantityUomId="ea"
    sequenceNum="20"
    instruction="Attach to front placket">
</ProductAssoc>

<!-- Zipper -->
<ProductAssoc
    productId="FTM-SHIRT-BLUE-M"
    productIdTo="FTM-ZIP-METAL-50CM"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01"
    quantity="1"
    quantityUomId="ea"
    sequenceNum="30"
    instruction="Install at front opening">
</ProductAssoc>

<!-- Care Label -->
<ProductAssoc
    productId="FTM-SHIRT-BLUE-M"
    productIdTo="FTM-LABEL-CARE-EN"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01"
    quantity="1"
    quantityUomId="ea"
    sequenceNum="40"
    instruction="Sew at inside collar">
</ProductAssoc>

<!-- Thread -->
<ProductAssoc
    productId="FTM-SHIRT-BLUE-M"
    productIdTo="FTM-THREAD-BLUE"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01"
    quantity="50"
    quantityUomId="m"
    scrapFactor="1.10"
    sequenceNum="50">
</ProductAssoc>
```

**BOM Summary (per unit):**
- 1.5m Cotton Fabric (with 20% scrap = 1.8m required)
- 6 Buttons
- 1 Zipper
- 1 Care Label
- 50m Thread (with 10% scrap = 55m required)

### 3. Manufacturing Routing

```xml
<!-- Routing for Shirt Manufacturing -->
<WorkEffort workEffortId="ROUTE-SHIRT-STD" workEffortTypeId="ROUTING">
    <workEffortName>Standard Shirt Manufacturing Route</workEffortName>
    <description>Standard routing for casual shirts</description>
</WorkEffort>

<!-- Task 1: Cutting -->
<WorkEffort workEffortId="TASK-CUT" workEffortTypeId="ROU_TASK">
    <workEffortName>Fabric Cutting</workEffortName>
    <description>Cut fabric according to pattern</description>
    <estimatedMilliSeconds>7200000</estimatedMilliSeconds> <!-- 2 hours per 100 units -->
    <fixedAssetId>MACHINE-CUTTING-AUTO</fixedAssetId>
    <locationDesc>Cutting Section</locationDesc>
</WorkEffort>

<WorkEffortAssoc
    workEffortIdFrom="ROUTE-SHIRT-STD"
    workEffortIdTo="TASK-CUT"
    workEffortAssocTypeId="ROUTING_COMPONENT"
    sequenceNum="10">
</WorkEffortAssoc>

<!-- Task 2: Sewing -->
<WorkEffort workEffortId="TASK-SEW" workEffortTypeId="ROU_TASK">
    <workEffortName>Shirt Sewing</workEffortName>
    <description>Sew all components together</description>
    <estimatedMilliSeconds>14400000</estimatedMilliSeconds> <!-- 4 hours per 100 units -->
    <fixedAssetId>MACHINE-SEWING-INDUSTRIAL</fixedAssetId>
    <locationDesc>Sewing Line 1</locationDesc>
</WorkEffort>

<WorkEffortAssoc
    workEffortIdFrom="ROUTE-SHIRT-STD"
    workEffortIdTo="TASK-SEW"
    workEffortAssocTypeId="ROUTING_COMPONENT"
    sequenceNum="20">
</WorkEffortAssoc>

<!-- Task 3: Quality Control -->
<WorkEffort workEffortId="TASK-QC" workEffortTypeId="ROU_TASK">
    <workEffortName>Quality Inspection</workEffortName>
    <description>Check stitching, buttons, measurements</description>
    <estimatedMilliSeconds>3600000</estimatedMilliSeconds> <!-- 1 hour per 100 units -->
    <locationDesc>QC Station</locationDesc>
</WorkEffort>

<WorkEffortAssoc
    workEffortIdFrom="ROUTE-SHIRT-STD"
    workEffortIdTo="TASK-QC"
    workEffortAssocTypeId="ROUTING_COMPONENT"
    sequenceNum="30">
</WorkEffortAssoc>

<!-- Task 4: Finishing & Packing -->
<WorkEffort workEffortId="TASK-PACK" workEffortTypeId="ROU_TASK">
    <workEffortName>Finishing and Packaging</workEffortName>
    <description>Iron, fold, package</description>
    <estimatedMilliSeconds>3600000</estimatedMilliSeconds> <!-- 1 hour per 100 units -->
    <locationDesc>Packing Area</locationDesc>
</WorkEffort>

<WorkEffortAssoc
    workEffortIdFrom="ROUTE-SHIRT-STD"
    workEffortIdTo="TASK-PACK"
    workEffortAssocTypeId="ROUTING_COMPONENT"
    sequenceNum="40">
</WorkEffortAssoc>
```

### 4. Facility & Locations

```xml
<!-- Main Manufacturing Facility -->
<Facility facilityId="FTM-FAC-MAIN" facilityTypeId="PLANT">
    <facilityName>FTM Main Manufacturing Plant</facilityName>
    <description>Primary garment manufacturing facility</description>
</Facility>

<!-- Warehouse Locations -->
<FacilityLocation facilityId="FTM-FAC-MAIN" locationSeqId="RAW-001">
    <areaId>RAW-MATERIALS</areaId>
    <description>Raw Materials Storage</description>
</FacilityLocation>

<FacilityLocation facilityId="FTM-FAC-MAIN" locationSeqId="WIP-001">
    <areaId>WORK-IN-PROGRESS</areaId>
    <description>Production Floor WIP</description>
</FacilityLocation>

<FacilityLocation facilityId="FTM-FAC-MAIN" locationSeqId="FG-001">
    <areaId>FINISHED-GOODS</areaId>
    <description>Finished Goods Warehouse</description>
</FacilityLocation>
```

### 5. Suppliers

```xml
<!-- Fabric Supplier -->
<Party partyId="SUPPLIER-FABRIC-ABC" partyTypeId="PARTY_GROUP">
    <PartyGroup groupName="ABC Fabric Mills Ltd"/>
</Party>

<PartyRole partyId="SUPPLIER-FABRIC-ABC" roleTypeId="SUPPLIER"/>

<SupplierProduct
    productId="FTM-FABRIC-COTTON-BLUE-45"
    partyId="SUPPLIER-FABRIC-ABC"
    availableFromDate="2025-01-01"
    supplierProductId="ABC-CTN-BLU-45"
    supplierProductName="Cotton Blue 45in"
    lastPrice="5.50"
    currencyUomId="USD"
    quantityUomId="m"
    minimumOrderQuantity="100"
    leadTimeDays="7"
    supplierRatingTypeId="QUALITY_HIGH">
</SupplierProduct>

<!-- Components Supplier -->
<Party partyId="SUPPLIER-COMPONENTS-XYZ" partyTypeId="PARTY_GROUP">
    <PartyGroup groupName="XYZ Garment Components"/>
</Party>

<PartyRole partyId="SUPPLIER-COMPONENTS-XYZ" roleTypeId="SUPPLIER"/>

<SupplierProduct
    productId="FTM-BTN-WHITE-20MM"
    partyId="SUPPLIER-COMPONENTS-XYZ"
    supplierProductId="XYZ-BTN-WHT-20"
    lastPrice="0.05"
    minimumOrderQuantity="1000"
    leadTimeDays="3">
</SupplierProduct>

<SupplierProduct
    productId="FTM-ZIP-METAL-50CM"
    partyId="SUPPLIER-COMPONENTS-XYZ"
    supplierProductId="XYZ-ZIP-MTL-50"
    lastPrice="0.80"
    minimumOrderQuantity="500"
    leadTimeDays="3">
</SupplierProduct>
```

### 6. Customer

```xml
<Party partyId="CUSTOMER-ABC-RETAIL" partyTypeId="PARTY_GROUP">
    <PartyGroup groupName="ABC Retail Store"/>
</Party>

<PartyRole partyId="CUSTOMER-ABC-RETAIL" roleTypeId="CUSTOMER"/>

<!-- Shipping Address -->
<PostalAddress contactMechId="ADDR-ABC-001">
    <toName>ABC Retail Store - Receiving</toName>
    <address1>123 Main Street</address1>
    <city>New York</city>
    <stateProvinceGeoId>NY</stateProvinceGeoId>
    <postalCode>10001</postalCode>
    <countryGeoId>USA</countryGeoId>
</PostalAddress>

<PartyContactMech
    partyId="CUSTOMER-ABC-RETAIL"
    contactMechId="ADDR-ABC-001"
    contactMechPurposeTypeId="SHIPPING_LOCATION"
    fromDate="2025-01-01">
</PartyContactMech>
```

### 7. Initial Inventory

```xml
<!-- Fabric Inventory -->
<InventoryItem
    inventoryItemId="INV-FABRIC-001"
    productId="FTM-FABRIC-COTTON-BLUE-45"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    inventoryItemTypeId="NON_SERIAL_INV_ITEM"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="1000"
    availableToPromiseTotal="1000"
    unitCost="5.50"
    currencyUomId="USD">
</InventoryItem>

<!-- Buttons Inventory -->
<InventoryItem
    inventoryItemId="INV-BTN-001"
    productId="FTM-BTN-WHITE-20MM"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="10000"
    availableToPromiseTotal="10000"
    unitCost="0.05">
</InventoryItem>

<!-- Zippers Inventory -->
<InventoryItem
    inventoryItemId="INV-ZIP-001"
    productId="FTM-ZIP-METAL-50CM"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    quantityOnHandTotal="5000"
    availableToPromiseTotal="5000"
    unitCost="0.80">
</InventoryItem>

<!-- Labels Inventory -->
<InventoryItem
    inventoryItemId="INV-LABEL-001"
    productId="FTM-LABEL-CARE-EN"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    quantityOnHandTotal="20000"
    availableToPromiseTotal="20000"
    unitCost="0.02">
</InventoryItem>

<!-- Thread Inventory -->
<InventoryItem
    inventoryItemId="INV-THREAD-001"
    productId="FTM-THREAD-BLUE"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    quantityOnHandTotal="50000"
    availableToPromiseTotal="50000"
    unitCost="0.01">
</InventoryItem>
```

---

## Workflow: Sales Order to Delivery

### Step 1: Sales Order Creation

**Date**: 2025-01-15
**Service**: `createOrderFromShoppingCart`

```xml
<OrderHeader orderId="SO-2025-001" orderTypeId="SALES_ORDER">
    <orderName>ABC Retail - Blue Shirts Order</orderName>
    <orderDate>2025-01-15 10:00:00</orderDate>
    <entryDate>2025-01-15 10:00:00</entryDate>
    <statusId>ORDER_CREATED</statusId>
    <currencyUom>USD</currencyUom>
    <billingAccountId></billingAccountId>
    <grandTotal>15000.00</grandTotal>
    <billingPartyId>CUSTOMER-ABC-RETAIL</billingPartyId>
    <partyId>CUSTOMER-ABC-RETAIL</partyId>
    <productStoreId>FTM_STORE</productStoreId>
</OrderHeader>

<OrderItem orderId="SO-2025-001" orderItemSeqId="00001">
    <orderItemTypeId>PRODUCT_ORDER_ITEM</orderItemTypeId>
    <productId>FTM-SHIRT-BLUE-M</productId>
    <prodCatalogId>FTM_CATALOG</prodCatalogId>
    <quantity>500</quantity>
    <selectedAmount>0</selectedAmount>
    <unitPrice>30.00</unitPrice>
    <unitListPrice>35.00</unitListPrice>
    <itemDescription>Men's Casual Shirt Blue Medium</itemDescription>
    <statusId>ITEM_CREATED</statusId>
    <estimatedDeliveryDate>2025-02-28</estimatedDeliveryDate>
</OrderItem>

<OrderItemShipGroup orderId="SO-2025-001" shipGroupSeqId="00001">
    <shipmentMethodTypeId>GROUND</shipmentMethodTypeId>
    <carrierPartyId>DHL</carrierPartyId>
    <contactMechId>ADDR-ABC-001</contactMechId>
    <facilityId>FTM-FAC-MAIN</facilityId>
</OrderItemShipGroup>

<OrderPaymentPreference orderId="SO-2025-001" orderPaymentPreferenceId="OPP-001">
    <paymentMethodTypeId>EXT_OFFLINE</paymentMethodTypeId>
    <maxAmount>15000.00</maxAmount>
    <statusId>PAYMENT_NOT_RECEIVED</statusId>
</OrderPaymentPreference>
```

**Service Call**:
```groovy
service: storeOrder
input:
  - orderId: SO-2025-001
  - orderTypeId: SALES_ORDER

result:
  - orderId: SO-2025-001
  - statusId: ORDER_APPROVED
```

### Step 2: MRP Planning

**Date**: 2025-01-15 (triggered automatically)
**Service**: `executeMrp`

**Material Requirements Calculation**:

For 500 units of FTM-SHIRT-BLUE-M:
- Fabric: 500 × 1.5m × 1.20 (scrap) = **900 meters**
- Buttons: 500 × 6 = **3,000 units**
- Zippers: 500 × 1 = **500 units**
- Labels: 500 × 1 = **500 units**
- Thread: 500 × 50m × 1.10 (scrap) = **27,500 meters**

**Current Inventory vs Requirements**:

| Material | Required | Available | Shortage |
|----------|----------|-----------|----------|
| Fabric | 900m | 1,000m | 0 ✓ |
| Buttons | 3,000 | 10,000 | 0 ✓ |
| Zippers | 500 | 5,000 | 0 ✓ |
| Labels | 500 | 20,000 | 0 ✓ |
| Thread | 27,500m | 50,000m | 0 ✓ |

**MRP Events Created**:

```xml
<!-- Demand Event -->
<MrpEvent mrpId="MRP-001" productId="FTM-SHIRT-BLUE-M">
    <mrpEventTypeId>DEMAND</mrpEventTypeId>
    <eventDate>2025-02-28</eventDate>
    <quantity>500</quantity>
    <facilityId>FTM-FAC-MAIN</facilityId>
    <eventName>Sales Order SO-2025-001</eventName>
</MrpEvent>

<!-- Component Demand Events -->
<MrpEvent mrpId="MRP-002" productId="FTM-FABRIC-COTTON-BLUE-45">
    <mrpEventTypeId>DEMAND</mrpEventTypeId>
    <eventDate>2025-02-01</eventDate>
    <quantity>900</quantity>
    <facilityId>FTM-FAC-MAIN</facilityId>
</MrpEvent>

<MrpEvent mrpId="MRP-003" productId="FTM-BTN-WHITE-20MM">
    <mrpEventTypeId>DEMAND</mrpEventTypeId>
    <eventDate>2025-02-01</eventDate>
    <quantity>3000</quantity>
    <facilityId>FTM-FAC-MAIN</facilityId>
</MrpEvent>

<!-- Supply Events (from existing inventory) -->
<MrpEvent mrpId="MRP-101" productId="FTM-FABRIC-COTTON-BLUE-45">
    <mrpEventTypeId>SUPPLY</mrpEventTypeId>
    <eventDate>2025-01-05</eventDate>
    <quantity>1000</quantity>
    <facilityId>FTM-FAC-MAIN</facilityId>
</MrpEvent>
```

**Result**: All materials available in stock. No purchase orders needed.

### Step 3: Production Run Creation

**Date**: 2025-02-01
**Service**: `createProductionRunsForOrder`

```xml
<WorkEffort workEffortId="PR-SH-BLU-M-001" workEffortTypeId="PROD_ORDER_HEADER">
    <workEffortName>Production Run - Blue Shirts M</workEffortName>
    <description>Manufacturing 500 units for SO-2025-001</description>
    <currentStatusId>PRUN_CREATED</currentStatusId>
    <facilityId>FTM-FAC-MAIN</facilityId>
    <workEffortPurposeTypeId>WEPT_PRODUCTION_RUN</workEffortPurposeTypeId>
    <estimatedStartDate>2025-02-01 08:00:00</estimatedStartDate>
    <estimatedCompletionDate>2025-02-20 17:00:00</estimatedCompletionDate>
    <quantityToProduce>500</quantityToProduce>
    <quantityProduced>0</quantityProduced>
    <quantityRejected>0</quantityRejected>
</WorkEffort>

<WorkEffortGoodStandard
    workEffortId="PR-SH-BLU-M-001"
    productId="FTM-SHIRT-BLUE-M"
    workEffortGoodStdTypeId="ROU_PROD_TEMPLATE"
    statusId="WEGS_CREATED"
    fromDate="2025-02-01"
    estimatedQuantity="500">
</WorkEffortGoodStandard>
```

**Production Tasks (from routing)**:

```xml
<!-- Task 1: Cutting -->
<WorkEffort workEffortId="PR-SH-BLU-M-001-CUT" workEffortTypeId="PROD_ORDER_TASK">
    <workEffortName>Cutting - 500 Shirts</workEffortName>
    <workEffortParentId>PR-SH-BLU-M-001</workEffortParentId>
    <currentStatusId>PRUN_CREATED</currentStatusId>
    <facilityId>FTM-FAC-MAIN</facilityId>
    <estimatedStartDate>2025-02-01 08:00:00</estimatedStartDate>
    <estimatedCompletionDate>2025-02-03 17:00:00</estimatedCompletionDate>
    <estimatedMilliSeconds>36000000</estimatedMilliSeconds> <!-- 10 hours -->
    <locationDesc>Cutting Section</locationDesc>
</WorkEffort>

<!-- Task 2: Sewing -->
<WorkEffort workEffortId="PR-SH-BLU-M-001-SEW" workEffortTypeId="PROD_ORDER_TASK">
    <workEffortName>Sewing - 500 Shirts</workEffortName>
    <workEffortParentId>PR-SH-BLU-M-001</workEffortParentId>
    <currentStatusId>PRUN_CREATED</currentStatusId>
    <estimatedStartDate>2025-02-03 08:00:00</estimatedStartDate>
    <estimatedCompletionDate>2025-02-15 17:00:00</estimatedCompletionDate>
    <estimatedMilliSeconds>72000000</estimatedMilliSeconds> <!-- 20 hours -->
    <locationDesc>Sewing Line 1</locationDesc>
</WorkEffort>

<!-- Task 3: QC -->
<WorkEffort workEffortId="PR-SH-BLU-M-001-QC" workEffortTypeId="PROD_ORDER_TASK">
    <workEffortName>Quality Control - 500 Shirts</workEffortName>
    <workEffortParentId>PR-SH-BLU-M-001</workEffortParentId>
    <estimatedStartDate>2025-02-15 08:00:00</estimatedStartDate>
    <estimatedCompletionDate>2025-02-18 17:00:00</estimatedCompletionDate>
    <estimatedMilliSeconds>18000000</estimatedMilliSeconds> <!-- 5 hours -->
    <locationDesc>QC Station</locationDesc>
</WorkEffort>

<!-- Task 4: Packing -->
<WorkEffort workEffortId="PR-SH-BLU-M-001-PACK" workEffortTypeId="PROD_ORDER_TASK">
    <workEffortName>Packing - 500 Shirts</workEffortName>
    <workEffortParentId>PR-SH-BLU-M-001</workEffortParentId>
    <estimatedStartDate>2025-02-18 08:00:00</estimatedStartDate>
    <estimatedCompletionDate>2025-02-20 17:00:00</estimatedCompletionDate>
    <estimatedMilliSeconds>18000000</estimatedMilliSeconds> <!-- 5 hours -->
    <locationDesc>Packing Area</locationDesc>
</WorkEffort>
```

### Step 4: Material Issuance

**Date**: 2025-02-01 (before production start)
**Service**: `issueInventoryItemToWorkEffort`

```xml
<!-- Issue Fabric -->
<InventoryItemDetail
    inventoryItemId="INV-FABRIC-001"
    inventoryItemDetailSeqId="0001"
    effectiveDate="2025-02-01 07:00:00">
    <quantityOnHandDiff>-900</quantityOnHandDiff>
    <availableToPromiseDiff>-900</availableToPromiseDiff>
    <description>Issued to PR-SH-BLU-M-001</description>
    <workEffortId>PR-SH-BLU-M-001</workEffortId>
</InventoryItemDetail>

<!-- Issue Buttons -->
<InventoryItemDetail
    inventoryItemId="INV-BTN-001"
    inventoryItemDetailSeqId="0001"
    effectiveDate="2025-02-01 07:00:00">
    <quantityOnHandDiff>-3000</quantityOnHandDiff>
    <availableToPromiseDiff>-3000</availableToPromiseDiff>
    <workEffortId>PR-SH-BLU-M-001</workEffortId>
</InventoryItemDetail>

<!-- Similar for other components -->
```

**Updated Inventory After Issuance**:

| Material | Before | Issued | Remaining |
|----------|--------|--------|-----------|
| Fabric | 1,000m | 900m | 100m |
| Buttons | 10,000 | 3,000 | 7,000 |
| Zippers | 5,000 | 500 | 4,500 |
| Labels | 20,000 | 500 | 19,500 |
| Thread | 50,000m | 27,500m | 22,500m |

### Step 5: Production Execution

#### Day 1-2: Cutting (2025-02-01 to 2025-02-03)

**Service**: `changeProductionRunTaskStatus`

```xml
<WorkEffort workEffortId="PR-SH-BLU-M-001-CUT">
    <currentStatusId>PRUN_RUNNING</currentStatusId>
    <actualStartDate>2025-02-01 08:00:00</actualStartDate>
</WorkEffort>
```

**WIP Inventory Created**:

```xml
<InventoryItem
    inventoryItemId="INV-WIP-CUT-001"
    productId="FTM-SHIRT-BLUE-M-CUT"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="WIP-001"
    inventoryItemTypeId="WIP_INVENTORY"
    quantityOnHandTotal="500"
    workEffortId="PR-SH-BLU-M-001-CUT">
</InventoryItem>
```

#### Day 3-15: Sewing (2025-02-03 to 2025-02-15)

```xml
<WorkEffort workEffortId="PR-SH-BLU-M-001-SEW">
    <currentStatusId>PRUN_RUNNING</currentStatusId>
    <actualStartDate>2025-02-03 08:00:00</actualStartDate>
</WorkEffort>
```

**Scrap/Rejection**:
- Started: 500 units
- Rejected during sewing: 10 units (2% scrap rate)
- Passed: 490 units

```xml
<WorkEffort workEffortId="PR-SH-BLU-M-001">
    <quantityRejected>10</quantityRejected>
</WorkEffort>

<InventoryItem
    inventoryItemId="INV-WIP-SEW-001"
    productId="FTM-SHIRT-BLUE-M-SEWN"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="WIP-001"
    quantityOnHandTotal="490">
</InventoryItem>
```

#### Day 15-18: Quality Control (2025-02-15 to 2025-02-18)

```xml
<WorkEffort workEffortId="PR-SH-BLU-M-001-QC">
    <currentStatusId>PRUN_RUNNING</currentStatusId>
    <actualStartDate>2025-02-15 08:00:00</actualStartDate>
</WorkEffort>
```

**QC Results**:
- Inspected: 490 units
- Failed QC: 5 units (1% failure rate)
- Passed: 485 units

```xml
<WorkEffort workEffortId="PR-SH-BLU-M-001">
    <quantityRejected>15</quantityRejected> <!-- Total: 10 + 5 -->
</WorkEffort>
```

#### Day 18-20: Packing (2025-02-18 to 2025-02-20)

```xml
<WorkEffort workEffortId="PR-SH-BLU-M-001-PACK">
    <currentStatusId>PRUN_RUNNING</currentStatusId>
    <actualStartDate>2025-02-18 08:00:00</actualStartDate>
    <actualCompletionDate>2025-02-20 16:00:00</actualCompletionDate>
</WorkEffort>

<WorkEffort workEffortId="PR-SH-BLU-M-001">
    <currentStatusId>PRUN_COMPLETED</currentStatusId>
    <quantityProduced>485</quantityProduced>
    <actualCompletionDate>2025-02-20 16:00:00</actualCompletionDate>
</WorkEffort>
```

### Step 6: Finished Goods Receipt

**Date**: 2025-02-20
**Service**: `receiveInventoryProduct`

```xml
<InventoryItem
    inventoryItemId="INV-FG-001"
    productId="FTM-SHIRT-BLUE-M"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="FG-001"
    inventoryItemTypeId="NON_SERIAL_INV_ITEM"
    datetimeReceived="2025-02-20 16:00:00"
    quantityOnHandTotal="485"
    availableToPromiseTotal="485"
    unitCost="18.50"
    currencyUomId="USD">
</InventoryItem>

<InventoryItemDetail
    inventoryItemId="INV-FG-001"
    inventoryItemDetailSeqId="0001"
    effectiveDate="2025-02-20 16:00:00">
    <quantityOnHandDiff>485</quantityOnHandDiff>
    <availableToPromiseDiff>485</availableToPromiseDiff>
    <description>Received from PR-SH-BLU-M-001</description>
    <workEffortId>PR-SH-BLU-M-001</workEffortId>
</InventoryItemDetail>
```

### Step 7: Shipment Creation

**Date**: 2025-02-22
**Service**: `createShipment`

```xml
<Shipment shipmentId="SHIP-2025-001" shipmentTypeId="SALES_SHIPMENT">
    <statusId>SHIPMENT_INPUT</statusId>
    <primaryOrderId>SO-2025-001</primaryOrderId>
    <primaryShipGroupSeqId>00001</primaryShipGroupSeqId>
    <estimatedReadyDate>2025-02-22</estimatedReadyDate>
    <estimatedShipDate>2025-02-23</estimatedShipDate>
    <estimatedArrivalDate>2025-02-28</estimatedArrivalDate>
    <partyIdFrom>FTM-GARMENTS</partyIdFrom>
    <partyIdTo>CUSTOMER-ABC-RETAIL</partyIdTo>
    <originFacilityId>FTM-FAC-MAIN</originFacilityId>
    <destinationContactMechId>ADDR-ABC-001</destinationContactMechId>
</Shipment>

<ShipmentItem shipmentId="SHIP-2025-001" shipmentItemSeqId="00001">
    <productId>FTM-SHIRT-BLUE-M</productId>
    <quantity>485</quantity>
</ShipmentItem>
```

### Step 8: Packing

**Date**: 2025-02-22
**Service**: `createShipmentPackage`

```xml
<!-- Carton 1 -->
<ShipmentPackage shipmentId="SHIP-2025-001" shipmentPackageSeqId="00001">
    <boxTypeId>CARTON-LARGE</boxTypeId>
    <weight>60</weight>
    <weightUomId>kg</weightUomId>
    <dimensionUomId>cm</dimensionUomId>
    <boxLength>100</boxLength>
    <boxWidth>60</boxWidth>
    <boxHeight>50</boxHeight>
</ShipmentPackage>

<!-- Similar for additional cartons... total 5 cartons -->
```

### Step 9: Shipping

**Date**: 2025-02-23
**Service**: `quickShipEntireOrder`

```xml
<ShipmentRouteSegment
    shipmentId="SHIP-2025-001"
    shipmentRouteSegmentId="00001">
    <originFacilityId>FTM-FAC-MAIN</originFacilityId>
    <destContactMechId>ADDR-ABC-001</destContactMechId>
    <carrierPartyId>DHL</carrierPartyId>
    <shipmentMethodTypeId>GROUND</shipmentMethodTypeId>
    <trackingIdNumber>DHL-2025-ABC-001234</trackingIdNumber>
    <actualStartDate>2025-02-23 10:00:00</actualStartDate>
    <estimatedArrivalDate>2025-02-28</estimatedArrivalDate>
</ShipmentRouteSegment>

<Shipment shipmentId="SHIP-2025-001">
    <statusId>SHIPMENT_SHIPPED</statusId>
    <actualShipDate>2025-02-23 10:00:00</actualShipDate>
</Shipment>

<OrderHeader orderId="SO-2025-001">
    <statusId>ORDER_COMPLETED</statusId>
</OrderHeader>
```

### Step 10: Delivery Confirmation

**Date**: 2025-02-27 (1 day early!)

```xml
<ShipmentRouteSegment
    shipmentId="SHIP-2025-001"
    shipmentRouteSegmentId="00001">
    <actualArrivalDate>2025-02-27 14:30:00</actualArrivalDate>
</ShipmentRouteSegment>

<Shipment shipmentId="SHIP-2025-001">
    <statusId>SHIPMENT_DELIVERED</statusId>
</Shipment>
```

---

## Service Call Sequences

### Complete End-to-End Service Execution

```groovy
// 1. CREATE SALES ORDER
service: createOrderFromShoppingCart
input:
  - shoppingCartId: CART-001
  - partyId: CUSTOMER-ABC-RETAIL
output:
  - orderId: SO-2025-001

// 2. APPROVE ORDER
service: changeOrderStatus
input:
  - orderId: SO-2025-001
  - statusId: ORDER_APPROVED

// 3. RUN MRP
service: executeMrp
input:
  - facilityId: FTM-FAC-MAIN
  - mrpName: Daily MRP Run
output:
  - mrpEvents created
  - requirements identified

// 4. CREATE PRODUCTION RUN
service: createProductionRunsForOrder
input:
  - orderId: SO-2025-001
  - facilityId: FTM-FAC-MAIN
  - routingId: ROUTE-SHIRT-STD
output:
  - productionRunId: PR-SH-BLU-M-001

// 5. CONFIRM PRODUCTION RUN
service: changeProductionRunStatus
input:
  - productionRunId: PR-SH-BLU-M-001
  - statusId: PRUN_DOC_PRINTED

// 6. ISSUE MATERIALS
service: issueInventoryItemToWorkEffort
input:
  - workEffortId: PR-SH-BLU-M-001
  - productId: FTM-FABRIC-COTTON-BLUE-45
  - quantity: 900

// (repeat for all materials)

// 7. START PRODUCTION
service: changeProductionRunTaskStatus
input:
  - productionRunId: PR-SH-BLU-M-001
  - workEffortId: PR-SH-BLU-M-001-CUT
  - statusId: PRUN_RUNNING

// 8. COMPLETE PRODUCTION TASKS
service: changeProductionRunTaskStatus
input:
  - workEffortId: PR-SH-BLU-M-001-CUT
  - statusId: PRUN_COMPLETED
  - quantityProduced: 500

// (repeat for SEW, QC, PACK tasks)

// 9. COMPLETE PRODUCTION RUN
service: changeProductionRunStatus
input:
  - productionRunId: PR-SH-BLU-M-001
  - statusId: PRUN_COMPLETED
  - quantityProduced: 485
  - quantityRejected: 15

// 10. CREATE SHIPMENT
service: createShipment
input:
  - primaryOrderId: SO-2025-001
  - shipmentTypeId: SALES_SHIPMENT
  - partyIdFrom: FTM-GARMENTS
  - partyIdTo: CUSTOMER-ABC-RETAIL
output:
  - shipmentId: SHIP-2025-001

// 11. ADD ITEMS TO SHIPMENT
service: createShipmentItem
input:
  - shipmentId: SHIP-2025-001
  - productId: FTM-SHIRT-BLUE-M
  - quantity: 485

// 12. PACK SHIPMENT
service: createShipmentPackage
input:
  - shipmentId: SHIP-2025-001
  - boxTypeId: CARTON-LARGE
  - weight: 60

// 13. SHIP
service: quickShipEntireOrder
input:
  - orderId: SO-2025-001
  - shipmentId: SHIP-2025-001
  - carrierPartyId: DHL
  - trackingIdNumber: DHL-2025-ABC-001234
```

---

## Integration Points

### 1. Order → MRP

**Trigger**: Order approval
**Event**: SECA (Service Event Condition Action)

```xml
<eca service="changeOrderStatus" event="commit">
    <condition field-name="statusId" operator="equals" value="ORDER_APPROVED"/>
    <action service="createAutoRequirementsForOrder" mode="sync"/>
</eca>
```

### 2. MRP → Production

**Trigger**: MRP event creation
**Manual/Scheduled**: Production planner reviews MRP events and creates production runs

### 3. Production → Inventory

**Trigger**: Production completion
**Service**: `receiveInventoryProduct`

### 4. Order → Shipment

**Trigger**: Order ready for shipment
**Manual**: Warehouse creates shipment based on available inventory

### 5. Shipment → Order Status

**Trigger**: Shipment shipped
**Auto**: Order status updated to COMPLETED

---

## Summary Metrics

| Metric | Value |
|--------|-------|
| **Order Value** | $15,000 USD |
| **Units Ordered** | 500 |
| **Units Produced** | 485 (97% yield) |
| **Units Scrapped** | 15 (3% scrap rate) |
| **Lead Time** | 38 days (order to delivery) |
| **Production Time** | 20 days |
| **Material Cost/Unit** | ~$12.50 |
| **Estimated Gross Margin** | ~$17.50/unit (58%) |

---

## Files Referenced

This workflow utilizes entities and services from:

- `/applications/datamodel/entitydef/order-entitymodel.xml`
- `/applications/datamodel/entitydef/product-entitymodel.xml`
- `/applications/datamodel/entitydef/manufacturing-entitymodel.xml`
- `/applications/datamodel/entitydef/workeffort-entitymodel.xml`
- `/applications/datamodel/entitydef/shipment-entitymodel.xml`
- `/applications/order/servicedef/services.xml`
- `/applications/manufacturing/servicedef/services_production_run.xml`
- `/applications/product/servicedef/services_shipment.xml`
- `/applications/product/servicedef/services_inventory.xml`

---

**Document Version**: 1.0
**Last Updated**: 2025-12-18
**Author**: FTM ERP Development Team
