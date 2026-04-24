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
**Order**: 300 units of Men's Casual Pant (32W x 32L, Navy Blue)
**Delivery Date**: 2025-02-28
**Order Value**: $21,000 USD (300 units × $70 retail price)

---

## Master Data Setup

### 1. Product Catalog

#### **Finished Goods**

```xml
<!-- Men's Casual Pant - Navy Blue, 32W x 32L -->
<Product productId="FTM-PNT-32-NVY" productTypeId="FINISHED_GOOD">
    <internalName>Men's Casual Pant 32W x 32L Navy Blue</internalName>
    <primaryProductCategoryId>CASUAL_PANTS</primaryProductCategoryId>
    <quantityUomId>ea</quantityUomId> <!-- each -->
    <defaultPrice>70.00</defaultPrice>
    <currencyUomId>USD</currencyUomId>
    <weight>0.45</weight>
    <weightUomId>kg</weightUomId>
</Product>

<!-- Product Features -->
<ProductFeature productFeatureId="COLOR_NAVY" productFeatureTypeId="COLOR">
    <description>Navy Blue</description>
</ProductFeature>

<ProductFeature productFeatureId="SIZE_32W32L" productFeatureTypeId="SIZE">
    <description>32W x 32L</description>
</ProductFeature>

<ProductFeatureAppl productId="FTM-PNT-32-NVY" productFeatureId="COLOR_NAVY" fromDate="2025-01-01"/>
<ProductFeatureAppl productId="FTM-PNT-32-NVY" productFeatureId="SIZE_32W32L" fromDate="2025-01-01"/>
```

#### **Raw Materials**

```xml
<!-- Main Fabric - Cotton Twill Navy, 60" width -->
<Product productId="FTM-FAB-CTN-NVY" productTypeId="RAW_MATERIAL">
    <internalName>Cotton Twill Fabric Navy 60 inch</internalName>
    <quantityUomId>m</quantityUomId> <!-- meter -->
    <defaultPrice>8.00</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Pocket Lining Fabric - Polyester White -->
<Product productId="FTM-FAB-PLY-PKT" productTypeId="RAW_MATERIAL">
    <internalName>Polyester Pocket Lining White</internalName>
    <quantityUomId>m</quantityUomId>
    <defaultPrice>3.00</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Metal Zipper 7 inch Brass -->
<Product productId="FTM-ZIP-7IN" productTypeId="RAW_MATERIAL">
    <internalName>Metal Zipper Brass 7 inch</internalName>
    <quantityUomId>ea</quantityUomId>
    <defaultPrice>0.80</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Metal Button 20mm Brass -->
<Product productId="FTM-BTN-BRS-20MM" productTypeId="RAW_MATERIAL">
    <internalName>Metal Button Brass 20mm</internalName>
    <quantityUomId>ea</quantityUomId>
    <defaultPrice>0.15</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Copper Rivets 10mm -->
<Product productId="FTM-RVT-10MM" productTypeId="RAW_MATERIAL">
    <internalName>Copper Rivet 10mm</internalName>
    <quantityUomId>ea</quantityUomId>
    <defaultPrice>0.05</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Sewing Thread - Navy Polyester -->
<Product productId="FTM-THD-NVY-CN" productTypeId="RAW_MATERIAL">
    <internalName>Polyester Sewing Thread Navy Cone</internalName>
    <quantityUomId>m</quantityUomId>
    <defaultPrice>0.01</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Brand Label - Woven -->
<Product productId="FTM-LBL-BRD" productTypeId="RAW_MATERIAL">
    <internalName>Brand Label Woven</internalName>
    <quantityUomId>ea</quantityUomId>
    <defaultPrice>0.20</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Care Label English -->
<Product productId="FTM-LBL-CAR" productTypeId="RAW_MATERIAL">
    <internalName>Care Label English Wash Instructions</internalName>
    <quantityUomId>ea</quantityUomId>
    <defaultPrice>0.10</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Size Label 32x32 -->
<Product productId="FTM-LABEL-SIZE-32X32" productTypeId="RAW_MATERIAL">
    <internalName>Size Label 32W x 32L</internalName>
    <quantityUomId>ea</quantityUomId>
    <defaultPrice>0.05</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Elastic Waistband 40mm -->
<Product productId="FTM-ELS-40-WHT" productTypeId="RAW_MATERIAL">
    <internalName>Elastic Waistband 40mm White</internalName>
    <quantityUomId>m</quantityUomId>
    <defaultPrice>0.50</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Fusible Interfacing -->
<Product productId="FTM-INT-FUS" productTypeId="RAW_MATERIAL">
    <internalName>Fusible Interfacing White</internalName>
    <quantityUomId>m</quantityUomId>
    <defaultPrice>1.50</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>

<!-- Poly Bag 12x16 -->
<Product productId="FTM-BAG-12X16" productTypeId="RAW_MATERIAL">
    <internalName>Poly Bag 12x16 inch Clear</internalName>
    <quantityUomId>ea</quantityUomId>
    <defaultPrice>0.08</defaultPrice>
    <currencyUomId>USD</currencyUomId>
</Product>
```

### 2. Bill of Materials (BOM)

```xml
<!-- BOM for FTM-PNT-32-NVY -->

<!-- Main Fabric -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-FAB-CTN-NVY"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1.8"
    quantityUomId="m"
    scrapFactor="1.15"
    sequenceNum="10"
    instruction="Cut according to pant pattern - front, back, pockets, waistband">
</ProductAssoc>

<!-- Pocket Lining -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-FAB-PLY-PKT"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="0.3"
    quantityUomId="m"
    scrapFactor="1.10"
    sequenceNum="20"
    instruction="Cut pocket lining - 4 pieces per pant">
</ProductAssoc>

<!-- Zipper -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-ZIP-7IN"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.02"
    sequenceNum="30"
    instruction="Install at front fly opening">
</ProductAssoc>

<!-- Button -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-BTN-BRS-20MM"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.05"
    sequenceNum="40"
    instruction="Attach at waistband closure">
</ProductAssoc>

<!-- Rivets -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-RVT-10MM"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="4"
    quantityUomId="ea"
    scrapFactor="1.10"
    sequenceNum="50"
    instruction="Install at pocket corners for reinforcement">
</ProductAssoc>

<!-- Main Sewing Thread -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-THD-NVY-CN"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="150"
    quantityUomId="m"
    scrapFactor="1.20"
    sequenceNum="60"
    instruction="Use for all main seams">
</ProductAssoc>

<!-- Brand Label -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-LBL-BRD"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.05"
    sequenceNum="70"
    instruction="Sew inside waistband at center back">
</ProductAssoc>

<!-- Care Label -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-LBL-CAR"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.03"
    sequenceNum="80"
    instruction="Sew inside waistband, left side seam">
</ProductAssoc>

<!-- Size Label -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-LABEL-SIZE-32X32"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.03"
    sequenceNum="90"
    instruction="Sew inside waistband, right side seam">
</ProductAssoc>

<!-- Elastic Waistband -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-ELS-40-WHT"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="0.9"
    quantityUomId="m"
    scrapFactor="1.05"
    sequenceNum="100"
    instruction="Insert inside waistband for support">
</ProductAssoc>

<!-- Interfacing -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-INT-FUS"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="0.4"
    quantityUomId="m"
    scrapFactor="1.10"
    sequenceNum="110"
    instruction="Iron-on to waistband for structure">
</ProductAssoc>

<!-- Poly Bag -->
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-BAG-12X16"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.02"
    sequenceNum="120"
    instruction="Fold pant and insert in poly bag">
</ProductAssoc>
```

**BOM Summary (per unit):**
- 1.8m Main Fabric (with 15% scrap = 2.07m required)
- 0.3m Pocket Lining (with 10% scrap = 0.33m required)
- 1 Zipper (with 2% scrap = 1.02 required)
- 1 Button (with 5% scrap = 1.05 required)
- 4 Rivets (with 10% scrap = 4.4 required)
- 150m Thread (with 20% scrap = 180m required)
- 3 Labels (brand, care, size)
- 0.9m Elastic (with 5% scrap = 0.95m required)
- 0.4m Interfacing (with 10% scrap = 0.44m required)
- 1 Poly Bag (with 2% scrap = 1.02 required)
- **Total Material Cost**: ~$25.52 per pant (see [BOM-DEEP-DIVE.md](BOM-DEEP-DIVE.md) for detailed cost breakdown)

### 3. Manufacturing Routing

```xml
<!-- Routing for Pant Manufacturing -->
<WorkEffort workEffortId="ROUTE-PANT-STD" workEffortTypeId="ROUTING">
    <workEffortName>Standard Pant Manufacturing Route</workEffortName>
    <description>Standard routing for casual pants</description>
</WorkEffort>

<!-- Task 1: Cutting -->
<WorkEffort workEffortId="TASK-CUT-PANT" workEffortTypeId="ROU_TASK">
    <workEffortName>Fabric Cutting</workEffortName>
    <description>Cut fabric according to pant pattern - front, back, pockets, waistband</description>
    <estimatedMilliSeconds>10800000</estimatedMilliSeconds> <!-- 3 hours per 100 units -->
    <fixedAssetId>MACHINE-CUTTING-AUTO</fixedAssetId>
    <locationDesc>Cutting Section</locationDesc>
</WorkEffort>

<WorkEffortAssoc
    workEffortIdFrom="ROUTE-PANT-STD"
    workEffortIdTo="TASK-CUT-PANT"
    workEffortAssocTypeId="ROUTING_COMPONENT"
    sequenceNum="10">
</WorkEffortAssoc>

<!-- Task 2: Sewing -->
<WorkEffort workEffortId="TASK-SEW-PANT" workEffortTypeId="ROU_TASK">
    <workEffortName>Pant Sewing</workEffortName>
    <description>Sew all components - inseams, outseams, pockets, zipper, waistband</description>
    <estimatedMilliSeconds>18000000</estimatedMilliSeconds> <!-- 5 hours per 100 units -->
    <fixedAssetId>MACHINE-SEWING-INDUSTRIAL</fixedAssetId>
    <locationDesc>Sewing Line 2</locationDesc>
</WorkEffort>

<WorkEffortAssoc
    workEffortIdFrom="ROUTE-PANT-STD"
    workEffortIdTo="TASK-SEW-PANT"
    workEffortAssocTypeId="ROUTING_COMPONENT"
    sequenceNum="20">
</WorkEffortAssoc>

<!-- Task 3: Finishing (Bartack, Rivets, Hemming) -->
<WorkEffort workEffortId="TASK-FINISH-PANT" workEffortTypeId="ROU_TASK">
    <workEffortName>Finishing Operations</workEffortName>
    <description>Install rivets, bartack stress points, hem legs</description>
    <estimatedMilliSeconds>7200000</estimatedMilliSeconds> <!-- 2 hours per 100 units -->
    <fixedAssetId>MACHINE-BARTACK</fixedAssetId>
    <locationDesc>Finishing Station</locationDesc>
</WorkEffort>

<WorkEffortAssoc
    workEffortIdFrom="ROUTE-PANT-STD"
    workEffortIdTo="TASK-FINISH-PANT"
    workEffortAssocTypeId="ROUTING_COMPONENT"
    sequenceNum="30">
</WorkEffortAssoc>

<!-- Task 4: Quality Control -->
<WorkEffort workEffortId="TASK-QC-PANT" workEffortTypeId="ROU_TASK">
    <workEffortName>Quality Inspection</workEffortName>
    <description>Check stitching, measurements, zipper, rivets, overall quality</description>
    <estimatedMilliSeconds>3600000</estimatedMilliSeconds> <!-- 1 hour per 100 units -->
    <locationDesc>QC Station</locationDesc>
</WorkEffort>

<WorkEffortAssoc
    workEffortIdFrom="ROUTE-PANT-STD"
    workEffortIdTo="TASK-QC-PANT"
    workEffortAssocTypeId="ROUTING_COMPONENT"
    sequenceNum="40">
</WorkEffortAssoc>

<!-- Task 5: Pressing & Packing -->
<WorkEffort workEffortId="TASK-PACK-PANT" workEffortTypeId="ROU_TASK">
    <workEffortName>Pressing and Packaging</workEffortName>
    <description>Press, fold, insert cardboard, poly bag, label</description>
    <estimatedMilliSeconds>5400000</estimatedMilliSeconds> <!-- 1.5 hours per 100 units -->
    <locationDesc>Packing Area</locationDesc>
</WorkEffort>

<WorkEffortAssoc
    workEffortIdFrom="ROUTE-PANT-STD"
    workEffortIdTo="TASK-PACK-PANT"
    workEffortAssocTypeId="ROUTING_COMPONENT"
    sequenceNum="50">
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
<!-- Main Fabric Inventory -->
<InventoryItem
    inventoryItemId="INV-FABRIC-001"
    productId="FTM-FAB-CTN-NVY"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    inventoryItemTypeId="NON_SERIAL_INV_ITEM"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="800"
    availableToPromiseTotal="800"
    unitCost="8.00"
    currencyUomId="USD">
</InventoryItem>

<!-- Pocket Lining Inventory -->
<InventoryItem
    inventoryItemId="INV-POCKET-LINING-001"
    productId="FTM-FAB-PLY-PKT"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="150"
    availableToPromiseTotal="150"
    unitCost="3.00">
</InventoryItem>

<!-- Zippers Inventory -->
<InventoryItem
    inventoryItemId="INV-ZIP-001"
    productId="FTM-ZIP-7IN"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="500"
    availableToPromiseTotal="500"
    unitCost="0.80">
</InventoryItem>

<!-- Buttons Inventory -->
<InventoryItem
    inventoryItemId="INV-BTN-001"
    productId="FTM-BTN-BRS-20MM"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="1000"
    availableToPromiseTotal="1000"
    unitCost="0.15">
</InventoryItem>

<!-- Rivets Inventory -->
<InventoryItem
    inventoryItemId="INV-RIVET-001"
    productId="FTM-RVT-10MM"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="5000"
    availableToPromiseTotal="5000"
    unitCost="0.05">
</InventoryItem>

<!-- Thread Inventory -->
<InventoryItem
    inventoryItemId="INV-THREAD-001"
    productId="FTM-THD-NVY-CN"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="100000"
    availableToPromiseTotal="100000"
    unitCost="0.01">
</InventoryItem>

<!-- Labels Inventory -->
<InventoryItem
    inventoryItemId="INV-LABEL-001"
    productId="FTM-LBL-BRD"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="2000"
    availableToPromiseTotal="2000"
    unitCost="0.20">
</InventoryItem>

<!-- Elastic Inventory -->
<InventoryItem
    inventoryItemId="INV-ELASTIC-001"
    productId="FTM-ELS-40-WHT"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="500"
    availableToPromiseTotal="500"
    unitCost="0.50">
</InventoryItem>

<!-- Interfacing Inventory -->
<InventoryItem
    inventoryItemId="INV-INTERFACING-001"
    productId="FTM-INT-FUS"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="200"
    availableToPromiseTotal="200"
    unitCost="1.50">
</InventoryItem>

<!-- Poly Bags Inventory -->
<InventoryItem
    inventoryItemId="INV-POLYBAG-001"
    productId="FTM-BAG-12X16"
    facilityId="FTM-FAC-MAIN"
    locationSeqId="RAW-001"
    datetimeReceived="2025-01-05"
    quantityOnHandTotal="5000"
    availableToPromiseTotal="5000"
    unitCost="0.08">
</InventoryItem>
```

---

## Workflow: Sales Order to Delivery

### Step 1: Sales Order Creation

**Date**: 2025-01-15
**Service**: `createOrderFromShoppingCart`

```xml
<OrderHeader orderId="SO-2025-001" orderTypeId="SALES_ORDER">
    <orderName>ABC Retail - Navy Pants Order</orderName>
    <orderDate>2025-01-15 10:00:00</orderDate>
    <entryDate>2025-01-15 10:00:00</entryDate>
    <statusId>ORDER_CREATED</statusId>
    <currencyUom>USD</currencyUom>
    <billingAccountId></billingAccountId>
    <grandTotal>21000.00</grandTotal>
    <billingPartyId>CUSTOMER-ABC-RETAIL</billingPartyId>
    <partyId>CUSTOMER-ABC-RETAIL</partyId>
    <productStoreId>FTM_STORE</productStoreId>
</OrderHeader>

<OrderItem orderId="SO-2025-001" orderItemSeqId="00001">
    <orderItemTypeId>PRODUCT_ORDER_ITEM</orderItemTypeId>
    <productId>FTM-PNT-32-NVY</productId>
    <prodCatalogId>FTM_CATALOG</prodCatalogId>
    <quantity>300</quantity>
    <selectedAmount>0</selectedAmount>
    <unitPrice>70.00</unitPrice>
    <unitListPrice>80.00</unitListPrice>
    <itemDescription>Men's Casual Pant 32W x 32L Navy Blue</itemDescription>
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

For 300 units of FTM-PNT-32-NVY:
- Main Fabric: 300 × 1.8m × 1.15 (scrap) = **621 meters**
- Pocket Lining: 300 × 0.3m × 1.10 (scrap) = **99 meters**
- Zippers: 300 × 1 × 1.02 (scrap) = **306 units**
- Buttons: 300 × 1 × 1.05 (scrap) = **315 units**
- Rivets: 300 × 4 × 1.10 (scrap) = **1,320 units**
- Thread: 300 × 150m × 1.20 (scrap) = **54,000 meters**
- Labels (all types): 300 × 3 × 1.03 (avg scrap) = **927 units**
- Elastic: 300 × 0.9m × 1.05 (scrap) = **283.5 meters**
- Interfacing: 300 × 0.4m × 1.10 (scrap) = **132 meters**
- Poly Bags: 300 × 1 × 1.02 (scrap) = **306 units**

**Current Inventory vs Requirements**:

| Material | Required | Available | Shortage |
|----------|----------|-----------|----------|
| Main Fabric | 621m | 800m | 0 ✓ |
| Pocket Lining | 99m | 150m | 0 ✓ |
| Zippers | 306 | 500 | 0 ✓ |
| Buttons | 315 | 1,000 | 0 ✓ |
| Rivets | 1,320 | 5,000 | 0 ✓ |
| Thread | 54,000m | 100,000m | 0 ✓ |
| Labels | 927 | 2,000 | 0 ✓ |
| Elastic | 283.5m | 500m | 0 ✓ |
| Interfacing | 132m | 200m | 0 ✓ |
| Poly Bags | 306 | 5,000 | 0 ✓ |

**MRP Events Created**:

```xml
<!-- Demand Event -->
<MrpEvent mrpId="MRP-001" productId="FTM-PNT-32-NVY">
    <mrpEventTypeId>DEMAND</mrpEventTypeId>
    <eventDate>2025-02-28</eventDate>
    <quantity>300</quantity>
    <facilityId>FTM-FAC-MAIN</facilityId>
    <eventName>Sales Order SO-2025-001</eventName>
</MrpEvent>

<!-- Component Demand Events -->
<MrpEvent mrpId="MRP-002" productId="FTM-FAB-CTN-NVY">
    <mrpEventTypeId>DEMAND</mrpEventTypeId>
    <eventDate>2025-02-01</eventDate>
    <quantity>621</quantity>
    <facilityId>FTM-FAC-MAIN</facilityId>
</MrpEvent>

<MrpEvent mrpId="MRP-003" productId="FTM-THD-NVY-CN">
    <mrpEventTypeId>DEMAND</mrpEventTypeId>
    <eventDate>2025-02-01</eventDate>
    <quantity>54000</quantity>
    <facilityId>FTM-FAC-MAIN</facilityId>
</MrpEvent>

<MrpEvent mrpId="MRP-004" productId="FTM-RVT-10MM">
    <mrpEventTypeId>DEMAND</mrpEventTypeId>
    <eventDate>2025-02-01</eventDate>
    <quantity>1320</quantity>
    <facilityId>FTM-FAC-MAIN</facilityId>
</MrpEvent>

<!-- Supply Events (from existing inventory) -->
<MrpEvent mrpId="MRP-101" productId="FTM-FAB-CTN-NVY">
    <mrpEventTypeId>SUPPLY</mrpEventTypeId>
    <eventDate>2025-01-05</eventDate>
    <quantity>800</quantity>
    <facilityId>FTM-FAC-MAIN</facilityId>
</MrpEvent>

<MrpEvent mrpId="MRP-102" productId="FTM-THD-NVY-CN">
    <mrpEventTypeId>SUPPLY</mrpEventTypeId>
    <eventDate>2025-01-05</eventDate>
    <quantity>100000</quantity>
    <facilityId>FTM-FAC-MAIN</facilityId>
</MrpEvent>
```

**Result**: All materials available in stock. No purchase orders needed for this production run.

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

## Importing Data into OFBiz

This section explains how to import the workflow dataset XML into your running OFBiz instance.

### Prerequisites

1. **OFBiz Installed**: OFBiz framework properly installed at `~/development/ofbiz-framework`
2. **Database Configured**: PostgreSQL database configured and accessible
3. **System Running**: OFBiz loaded with seed data (`./gradlew loadAll`)
4. **Data File Ready**: XML file prepared with entity data

### Method 1: Command Line Import (Recommended)

This is the most reliable method for importing large datasets.

#### Step 1: Prepare Your Data File

Create an XML file with proper structure:

```bash
# Create data directory in your plugin
mkdir -p ~/development/ofbiz-plugins/ftm-garments/data

# Create the data file
nano ~/development/ofbiz-plugins/ftm-garments/data/FtmWorkflowData.xml
```

**File Structure**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<entity-engine-xml>
    <!-- Product Catalog -->
    <Product productId="FTM-PNT-32-NVY" productTypeId="FINISHED_GOOD">
        <internalName>Men's Casual Pant 32W x 32L Navy Blue</internalName>
        <primaryProductCategoryId>CASUAL_PANTS</primaryProductCategoryId>
        <quantityUomId>ea</quantityUomId>
        <defaultPrice>70.00</defaultPrice>
        <currencyUomId>USD</currencyUomId>
    </Product>

    <!-- BOM -->
    <ProductAssoc
        productId="FTM-PNT-32-NVY"
        productIdTo="FTM-FAB-CTN-NVY"
        productAssocTypeId="MANUF_COMPONENT"
        fromDate="2025-01-01 00:00:00"
        quantity="1.8"
        scrapFactor="1.15"
        sequenceNum="10"/>

    <!-- Add all other entities here -->
</entity-engine-xml>
```

#### Step 2: Import Using Gradle

```bash
# Navigate to OFBiz framework directory
cd ~/development/ofbiz-framework

# Import the data file
./gradlew "ofbiz --load-data file=plugins/ftm-garments/data/FtmWorkflowData.xml"

# Alternative: Load specific readers
./gradlew "ofbiz --load-data file=plugins/ftm-garments/data/FtmWorkflowData.xml readers=ext"
```

**Expected Output**:

```
> Task :ofbiz
...
2025-01-15 10:00:00,123 |main |GenericDelegator |I| [File Import] : Beginning import from file ...
2025-01-15 10:00:00,456 |main |GenericDelegator |I| [File Import] : Finished importing 150 entities
```

### Method 2: WebTools Import (Web UI)

For smaller datasets or quick testing.

#### Steps:

1. **Start OFBiz**:
   ```bash
   cd ~/development/ofbiz-framework
   ./gradlew ofbiz
   ```

2. **Access WebTools**:
   - Open browser: https://localhost:8443/webtools
   - Login: admin / ofbiz

3. **Navigate to Import**:
   - Click: **Entity Engine Tools**
   - Click: **Entity XML Import**

4. **Upload or Paste XML**:
   - **Option A** - Upload File:
     - Click "Browse" and select your XML file
     - Click "Import Text"

   - **Option B** - Paste XML:
     - Copy your XML content
     - Paste into the text area
     - Click "Import Text"

5. **Verify Import**:
   - Check the log output for errors
   - Use Entity Data Maintenance to verify records

### Method 3: Include in Plugin Data Load

For data that should always be loaded with your plugin.

#### Step 1: Configure Plugin Component

Edit `~/development/ofbiz-plugins/ftm-garments/ofbiz-component.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ofbiz-component name="ftm-garments">
    <!-- ... existing configuration ... -->

    <!-- Data Readers -->
    <entity-resource type="data" reader-name="seed" loader="main" location="data/FtmSeedData.xml"/>
    <entity-resource type="data" reader-name="demo" loader="main" location="data/FtmDemoData.xml"/>
    <entity-resource type="data" reader-name="ext" loader="main" location="data/FtmWorkflowData.xml"/>
</ofbiz-component>
```

#### Step 2: Load Plugin Data

```bash
cd ~/development/ofbiz-framework

# Load all data including plugin data
./gradlew loadAll

# Or load specific readers
./gradlew "ofbiz --load-data readers=seed,demo,ext"

# Or load specific plugin only
./gradlew "ofbiz --load-data component=ftm-garments"
```

### Data Import Best Practices

#### 1. **Use Proper Data Readers**

| Reader | Purpose | When to Use |
|--------|---------|-------------|
| `seed` | Essential system data | Required entities, enumerations |
| `seed-initial` | Initial setup data | Users, security, configurations |
| `demo` | Demonstration data | Sample products, orders |
| `ext` | External/custom data | Your business data |

#### 2. **Order of Data Import**

**Critical**: Import entities in dependency order:

```
1. Product Catalog (products must exist before BOM)
2. Facilities (facilities before inventory)
3. Parties (customers, suppliers)
4. BOM (requires products)
5. Inventory (requires products and facilities)
6. Orders (requires products and parties)
7. Production Runs (requires BOM and facilities)
```

**Example Correct Order**:

```xml
<entity-engine-xml>
    <!-- 1. Products First -->
    <Product productId="FTM-PANT-001" .../>
    <Product productId="FTM-FABRIC-001" .../>

    <!-- 2. Then BOM (references products) -->
    <ProductAssoc productId="FTM-PANT-001" productIdTo="FTM-FABRIC-001" .../>

    <!-- 3. Then Inventory (references products) -->
    <InventoryItem productId="FTM-FABRIC-001" .../>
</entity-engine-xml>
```

#### 3. **Handle Dates Properly**

```xml
<!-- ISO 8601 format: YYYY-MM-DD HH:MM:SS -->
<ProductAssoc fromDate="2025-01-01 00:00:00"/>

<!-- For date fields without time -->
<OrderHeader orderDate="2025-01-15 10:00:00"/>
```

#### 4. **Use Transactions**

Large imports are automatically wrapped in transactions. If one entity fails, entire file rolls back.

#### 5. **Validate Before Import**

```bash
# Check XML syntax
xmllint --noout data/FtmWorkflowData.xml

# If valid, no output. If errors, you'll see them.
```

### Troubleshooting

#### Error: "Entity not found"

**Cause**: Trying to import entity that doesn't exist in data model

**Solution**: Check entity name spelling in `entitymodel.xml` files

```bash
# Search for entity definition
grep -r "entity-name=\"ProductAssoc\"" applications/datamodel/entitydef/
```

#### Error: "Foreign key constraint violation"

**Cause**: Referencing an ID that doesn't exist (e.g., productId that hasn't been created yet)

**Solution**: Import dependencies first

```xml
<!-- Wrong Order -->
<ProductAssoc productIdTo="FTM-FABRIC-001" .../> <!-- Fails: fabric doesn't exist -->
<Product productId="FTM-FABRIC-001" .../>

<!-- Correct Order -->
<Product productId="FTM-FABRIC-001" .../> <!-- Create product first -->
<ProductAssoc productIdTo="FTM-FABRIC-001" .../> <!-- Then reference it -->
```

#### Error: "Duplicate key"

**Cause**: Trying to import record with same primary key that already exists

**Solution Option 1** - Skip existing:
```bash
./gradlew "ofbiz --load-data file=data.xml readers=ext"
# Add continue-on-error flag in XML:
```

```xml
<entity-engine-xml continue-on-error="true">
    <!-- data here -->
</entity-engine-xml>
```

**Solution Option 2** - Clear existing data first:
```sql
-- Careful! This deletes data
DELETE FROM product WHERE product_id LIKE 'FTM-%';
```

#### Error: "Parse error"

**Cause**: Invalid XML syntax

**Solution**: Validate XML structure
```bash
# Check for common issues:
# - Unclosed tags
# - Missing quotes around attributes
# - Invalid characters (< > & must be escaped)
# - Wrong encoding

xmllint --noout data/FtmWorkflowData.xml
```

#### Viewing Import Logs

```bash
# Real-time log viewing
tail -f ~/development/ofbiz-framework/runtime/logs/ofbiz.log

# Search for import errors
grep "ERROR" runtime/logs/ofbiz.log | grep -i "import"

# See import statistics
grep "Finished importing" runtime/logs/ofbiz.log
```

### Verifying Successful Import

#### Method 1: WebTools Entity Data Maintenance

1. Open: https://localhost:8443/webtools/control/EntityDataMaintenance
2. Select entity: e.g., "Product"
3. Click "Find"
4. Verify your data appears

#### Method 2: Database Query

```sql
-- Connect to database
psql -U ftmuser -d ftmerp

-- Check products
SELECT product_id, internal_name FROM product WHERE product_id LIKE 'FTM-%';

-- Check BOM
SELECT product_id, product_id_to, quantity, scrap_factor
FROM product_assoc
WHERE product_id = 'FTM-PNT-32-NVY';

-- Count imported records
SELECT COUNT(*) FROM product WHERE product_id LIKE 'FTM-%';
```

#### Method 3: Check Logs

```bash
grep "FTM-PNT-32-NVY" runtime/logs/ofbiz.log
```

### Exporting Existing Data

To export current data for backup or migration:

#### Using WebTools:

1. Navigate to: Entity Engine Tools → Entity XML Data Export
2. Select entities to export
3. Click "Export"

#### Using Command Line:

```bash
# Export all data from specific entities
./gradlew "ofbiz --export entityIds=Product,ProductAssoc,InventoryItem file=export.xml"

# Export with date filter
./gradlew "ofbiz --export entityIds=OrderHeader fromDate=2025-01-01 file=orders-export.xml"
```

### Quick Reference: Import Commands

```bash
# Import single file
./gradlew "ofbiz --load-data file=plugins/ftm-garments/data/FtmWorkflowData.xml"

# Import with specific reader
./gradlew "ofbiz --load-data file=data.xml readers=ext"

# Import multiple files
./gradlew "ofbiz --load-data dir=plugins/ftm-garments/data"

# Import and continue on errors
./gradlew "ofbiz --load-data file=data.xml timeout=7200"

# Reload ALL data (clears database!)
./gradlew loadAll
```

### Complete Import Workflow Example

```bash
# 1. Prepare data
cd ~/development/ofbiz-plugins/ftm-garments
mkdir -p data
nano data/FtmWorkflowData.xml
# (paste your XML data)

# 2. Validate XML
xmllint --noout data/FtmWorkflowData.xml

# 3. Start OFBiz (if not running)
cd ~/development/ofbiz-framework
./gradlew ofbiz &

# 4. Wait for startup (check log)
tail -f runtime/logs/ofbiz.log
# Wait for: "Started org.apache.ofbiz.catalina.container.CatalinaContainer"
# Ctrl+C to exit tail

# 5. Import data
./gradlew "ofbiz --load-data file=plugins/ftm-garments/data/FtmWorkflowData.xml"

# 6. Verify import
psql -U ftmuser -d ftmerp -c "SELECT COUNT(*) FROM product WHERE product_id LIKE 'FTM-%';"

# 7. Check in browser
# Open: https://localhost:8443/catalog/control/EditProduct?productId=FTM-PNT-32-NVY
```

---

**Document Version**: 1.0
**Last Updated**: 2025-12-19
**Author**: FTM ERP Development Team
**Related Documents**: [BOM-DEEP-DIVE.md](BOM-DEEP-DIVE.md), [OFBIZ-LEARNING-GUIDE.md](OFBIZ-LEARNING-GUIDE.md)
