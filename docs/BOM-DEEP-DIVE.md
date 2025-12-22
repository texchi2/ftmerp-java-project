# Bill of Materials (BOM) Deep Dive for Garment Manufacturing

Comprehensive guide to understanding and implementing BOM in Apache OFBiz for FTM Garments.

---

> **Note on Product IDs**: All product IDs in this document have been shortened to meet OFBiz's 20-character limit for the `Product.productId` field (VARCHAR(20)). Abbreviated codes are used (e.g., `FTM-PNT-32-NVY` instead of `FTM-PANT-CASUAL-32X32-NAVY`), while full descriptive names are retained in the `internalName` field.

---

## What is a Bill of Materials (BOM)?

A **Bill of Materials** (BOM) is the complete, structured list of all raw materials, components, sub-assemblies, and quantities required to manufacture a finished product.

### Why BOM is Critical

In garment manufacturing, the BOM is the **foundation** of:
- **Material Requirements Planning (MRP)** - What to buy and when
- **Cost Calculation** - Total production cost
- **Production Planning** - What materials are needed for manufacturing
- **Inventory Management** - Tracking raw material consumption
- **Purchase Orders** - Ordering correct quantities from suppliers

**Without an accurate BOM, you cannot:**
- Calculate accurate production costs
- Order the right materials
- Plan production efficiently
- Track inventory properly

---

## BOM Structure in OFBiz

### Entity: ProductAssoc

```xml
<entity entity-name="ProductAssoc" package-name="org.apache.ofbiz.product.product">
    <!-- Parent product (finished good) -->
    <field name="productId" type="id"></field>

    <!-- Component product (raw material) -->
    <field name="productIdTo" type="id"></field>

    <!-- Type of association -->
    <field name="productAssocTypeId" type="id"></field>
    <!-- Common values: MANUF_COMPONENT, PRODUCT_COMPONENT -->

    <!-- Validity period -->
    <field name="fromDate" type="date-time"></field>
    <field name="thruDate" type="date-time"></field>

    <!-- Quantity needed per parent unit -->
    <field name="quantity" type="fixed-point"></field>

    <!-- Waste/scrap percentage (1.15 = 15% waste) -->
    <field name="scrapFactor" type="fixed-point"></field>

    <!-- Sequence for assembly order -->
    <field name="sequenceNum" type="numeric"></field>

    <!-- Assembly instructions -->
    <field name="instruction" type="long-varchar"></field>

    <!-- Related production task -->
    <field name="routingWorkEffortId" type="id"></field>

    <prim-key field="productId"/>
    <prim-key field="productIdTo"/>
    <prim-key field="productAssocTypeId"/>
    <prim-key field="fromDate"/>
</entity>
```

---

## Real-World Example: Men's Casual Pant BOM

### Product Overview

**Product**: Men's Casual Pant (32W x 32L, Navy Blue)
**Product ID**: `FTM-PNT-32-NVY`
**Finished Product**: 1 pair of pants

### Complete BOM Breakdown

#### 1. Fabric Components

##### Main Fabric (Body)
```xml
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
```

**Breakdown**:
- Base requirement: 1.8 meters per pant
- Scrap factor: 1.15 (15% waste from cutting)
- **Actual fabric needed**: 1.8m × 1.15 = **2.07 meters per pant**
- Fabric width: 60 inches
- Fabric type: Cotton twill

**Why 15% scrap?**
- Pattern cutting waste (irregular shapes)
- Fabric defects (need to cut around)
- Shrinkage allowance
- Quality control cuts

##### Pocket Lining Fabric
```xml
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
```

**Breakdown**:
- Base requirement: 0.3 meters
- Scrap factor: 1.10 (10% waste)
- **Actual needed**: 0.3m × 1.10 = **0.33 meters**
- 4 pocket linings per pant (2 front, 2 back)

#### 2. Fasteners and Hardware

##### Zipper
```xml
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
```

**Breakdown**:
- 1 zipper per pant
- Length: 7 inches
- Type: Metal brass (YKK or equivalent)
- Scrap factor: 1.02 (2% defect/damage rate)
- **Actual needed per 100 pants**: 102 zippers

##### Button
```xml
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
```

**Breakdown**:
- 1 button per pant
- Size: 20mm diameter
- Material: Brass metal
- Scrap factor: 1.05 (5% defect rate)

##### Rivets (for pockets)
```xml
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
```

**Breakdown**:
- 4 rivets per pant (2 front pockets, 2 back pockets)
- Size: 10mm
- Material: Copper
- Purpose: Pocket reinforcement

#### 3. Thread and Sewing Consumables

##### Main Sewing Thread
```xml
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
```

**Breakdown**:
- Base requirement: 150 meters per pant
- Scrap factor: 1.20 (20% waste)
- **Actual needed**: 150m × 1.20 = **180 meters per pant**
- Type: Polyester thread, navy color match
- Cone size: Typically 5,000m cones

**Why 20% thread scrap?**
- Thread breaks during sewing
- Tension adjustments
- Thread trimming at seam ends
- Bobbin changes (leftover thread)
- Machine threading

##### Bartack/Reinforcement Thread
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-THD-NVY-HV"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="5"
    quantityUomId="m"
    scrapFactor="1.10"
    sequenceNum="70"
    instruction="Use for bartacks at stress points">
</ProductAssoc>
```

**Breakdown**:
- 5 meters per pant
- Used for reinforcement stitching
- Bartack locations: zipper ends, pocket corners, belt loops

#### 4. Labels and Tags

##### Brand Label (Main)
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-LBL-BRD"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.05"
    sequenceNum="80"
    instruction="Sew inside waistband at center back">
</ProductAssoc>
```

##### Care Label
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-LBL-CAR"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.03"
    sequenceNum="90"
    instruction="Sew inside waistband, left side seam">
</ProductAssoc>
```

##### Size Label
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-LABEL-SIZE-32X32"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.03"
    sequenceNum="100"
    instruction="Sew inside waistband, right side seam">
</ProductAssoc>
```

##### Hangtag
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-HANGTAG-RETAIL"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.02"
    sequenceNum="110"
    instruction="Attach at waistband with plastic fastener">
</ProductAssoc>
```

#### 5. Trims and Accessories

##### Belt Loops
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-FAB-CTN-NVY"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="0.3"
    quantityUomId="m"
    scrapFactor="1.15"
    sequenceNum="115"
    instruction="Cut 7 belt loops, 10cm each, from main fabric">
</ProductAssoc>
```

**Breakdown**:
- 7 belt loops per pant
- Each loop: ~10cm long
- Total: 0.7m (accounting for width)
- Uses same main fabric
- Cut and folded before attaching

##### Elastic (waistband inner support)
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-ELS-40-WHT"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="0.9"
    quantityUomId="m"
    scrapFactor="1.05"
    sequenceNum="120"
    instruction="Insert inside waistband for support">
</ProductAssoc>
```

**Breakdown**:
- 0.9 meters per pant
- Width: 40mm
- Sewn inside waistband for structure
- Provides comfort and fit

##### Interfacing (waistband stiffening)
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-INT-FUS"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="0.4"
    quantityUomId="m"
    scrapFactor="1.10"
    sequenceNum="130"
    instruction="Iron-on to waistband for structure">
</ProductAssoc>
```

**Breakdown**:
- 0.4 meters per pant
- Fusible (iron-on) type
- Applied to waistband before sewing
- Provides structure and prevents stretching

#### 6. Packaging Materials

##### Poly Bag
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-BAG-12X16"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.02"
    sequenceNum="140"
    instruction="Fold pant and insert in poly bag">
</ProductAssoc>
```

##### Cardboard Insert (for folding)
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-CRD-PNT"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.01"
    sequenceNum="150"
    instruction="Insert for neat folding and display">
</ProductAssoc>
```

##### Barcode Sticker
```xml
<ProductAssoc
    productId="FTM-PNT-32-NVY"
    productIdTo="FTM-BARCODE-STICKER"
    productAssocTypeId="MANUF_COMPONENT"
    fromDate="2025-01-01 00:00:00"
    quantity="1"
    quantityUomId="ea"
    scrapFactor="1.01"
    sequenceNum="160"
    instruction="Apply to poly bag">
</ProductAssoc>
```

---

## Complete BOM Summary for One Pant

| Component | Product ID | Quantity | Unit | Scrap | Actual Qty | Unit Cost | Total Cost |
|-----------|-----------|----------|------|-------|------------|-----------|------------|
| **Fabric** |
| Main Fabric | FTM-FAB-CTN-NVY | 1.8 | m | 15% | 2.07 m | $8.00/m | $16.56 |
| Pocket Lining | FTM-FAB-PLY-PKT | 0.3 | m | 10% | 0.33 m | $3.00/m | $0.99 |
| Belt Loop Fabric | (from main fabric) | 0.3 | m | 15% | 0.35 m | $8.00/m | $2.80 |
| **Fasteners** |
| Zipper | FTM-ZIP-7IN | 1 | ea | 2% | 1.02 | $0.80/ea | $0.82 |
| Button | FTM-BTN-BRS-20MM | 1 | ea | 5% | 1.05 | $0.15/ea | $0.16 |
| Rivets | FTM-RVT-10MM | 4 | ea | 10% | 4.4 | $0.05/ea | $0.22 |
| **Thread** |
| Main Thread | FTM-THD-NVY-CN | 150 | m | 20% | 180 m | $0.01/m | $1.80 |
| Reinforcement Thread | FTM-THD-NVY-HV | 5 | m | 10% | 5.5 m | $0.02/m | $0.11 |
| **Labels** |
| Brand Label | FTM-LBL-BRD | 1 | ea | 5% | 1.05 | $0.20/ea | $0.21 |
| Care Label | FTM-LBL-CAR | 1 | ea | 3% | 1.03 | $0.10/ea | $0.10 |
| Size Label | FTM-LABEL-SIZE-32X32 | 1 | ea | 3% | 1.03 | $0.05/ea | $0.05 |
| Hangtag | FTM-HANGTAG-RETAIL | 1 | ea | 2% | 1.02 | $0.30/ea | $0.31 |
| **Trims** |
| Elastic | FTM-ELS-40-WHT | 0.9 | m | 5% | 0.95 m | $0.50/m | $0.48 |
| Interfacing | FTM-INT-FUS | 0.4 | m | 10% | 0.44 m | $1.50/m | $0.66 |
| **Packaging** |
| Poly Bag | FTM-BAG-12X16 | 1 | ea | 2% | 1.02 | $0.08/ea | $0.08 |
| Cardboard Insert | FTM-CRD-PNT | 1 | ea | 1% | 1.01 | $0.15/ea | $0.15 |
| Barcode Sticker | FTM-BARCODE-STICKER | 1 | ea | 1% | 1.01 | $0.02/ea | $0.02 |
| **TOTAL MATERIAL COST** | | | | | | | **$25.52** |

### Additional Costs (not in BOM)
- Direct Labor: $8.00 per pant
- Manufacturing Overhead: $3.50 per pant
- **Total Production Cost**: $37.02 per pant

---

## How BOM Drives MRP

### From Sales Order to Material Requirements

**Scenario**: Customer orders 1,000 pants (FTM-PNT-32-NVY)

**Step 1: BOM Explosion**

MRP explodes the BOM for 1,000 units:

| Material | Per Unit | For 1,000 Units | Current Stock | Shortage | Order Qty |
|----------|----------|-----------------|---------------|----------|-----------|
| Main Fabric (m) | 2.07 | 2,070 | 500 | 1,570 | **1,600** (round up) |
| Pocket Lining (m) | 0.33 | 330 | 100 | 230 | **250** |
| Zippers (ea) | 1.02 | 1,020 | 500 | 520 | **600** (min order 100) |
| Buttons (ea) | 1.05 | 1,050 | 2,000 | 0 | **0** (sufficient) |
| Main Thread (m) | 180 | 180,000 | 50,000 | 130,000 | **150,000** (buy 3 cones) |

**Step 2: Create Requirements**

```sql
-- MRP generates requirements
INSERT INTO requirement (
    requirement_id,
    requirement_type_id,
    product_id,
    quantity,
    requirement_date,
    facility_id
) VALUES
('REQ-2025-001', 'MATERIAL_REQUIREMENT', 'FTM-FAB-CTN-NVY', 1600, '2025-02-01', 'FTM-FAC-MAIN'),
('REQ-2025-002', 'MATERIAL_REQUIREMENT', 'FTM-FAB-PLY-PKT', 250, '2025-02-01', 'FTM-FAC-MAIN'),
('REQ-2025-003', 'MATERIAL_REQUIREMENT', 'FTM-ZIP-7IN', 600, '2025-02-01', 'FTM-FAC-MAIN');
```

**Step 3: Assign to Suppliers**

```sql
-- Look up supplier for each material
SELECT sp.party_id, sp.last_price, sp.minimum_order_quantity, sp.lead_time_days
FROM supplier_product sp
WHERE sp.product_id = 'FTM-FAB-CTN-NVY'
AND sp.available_from_date <= CURRENT_DATE
ORDER BY sp.supplier_ranking_preference
LIMIT 1;

-- Result: Supplier ABC, Price $8.00/m, Min 100m, Lead time 7 days
```

**Step 4: Create Purchase Orders**

```xml
<OrderHeader orderId="PO-2025-001" orderTypeId="PURCHASE_ORDER">
    <orderDate>2025-01-20</orderDate>
    <partyId>SUPPLIER-FABRIC-ABC</partyId>
</OrderHeader>

<OrderItem orderId="PO-2025-001" orderItemSeqId="00001">
    <productId>FTM-FAB-CTN-NVY</productId>
    <quantity>1600</quantity>
    <unitPrice>8.00</unitPrice>
</OrderItem>
```

**Step 5: Schedule Production**

Once materials are available (or scheduled to arrive), create production run:

```xml
<WorkEffort workEffortId="PR-PANT-001" workEffortTypeId="PROD_ORDER_HEADER">
    <productId>FTM-PNT-32-NVY</productId>
    <quantityToProduce>1000</quantityToProduce>
    <estimatedStartDate>2025-02-08</estimatedStartDate>
</WorkEffort>
```

---

## BOM Management Best Practices

### 1. Accurate Scrap Factors

**Test and Measure**:
- Run pilot production
- Measure actual material usage
- Calculate real waste percentage
- Update scrap factors regularly

**Example Testing Process**:
```
Pilot run: 10 pants
Main fabric issued: 20.7m (2.07m × 10)
Main fabric actually used: 18.5m
Waste: 2.2m (10.6%)

Current scrap factor: 1.15 (15%)
Actual waste: 10.6%
→ Can reduce scrap factor to 1.12 (12%) with safety margin
```

### 2. Version Control

When changing BOM, use date-based versions:

```xml
<!-- Old BOM - expire old version -->
<ProductAssoc productId="FTM-PNT-32-NVY"
              productIdTo="FTM-ZIP-7IN"
              fromDate="2025-01-01"
              thruDate="2025-02-28">  <!-- Expire old version -->
    <quantity>1</quantity>
</ProductAssoc>

<!-- New BOM - use longer zipper -->
<ProductAssoc productId="FTM-PNT-32-NVY"
              productIdTo="FTM-ZIP-METAL-BRASS-9INCH"
              fromDate="2025-03-01">  <!-- New version -->
    <quantity>1</quantity>
</ProductAssoc>
```

### 3. Multi-Level BOM

For complex products, create sub-assemblies:

```
Men's Pant (finished product)
  ├─ Pant Body Assembly (sub-assembly)
  │   ├─ Front Panel (cut parts)
  │   ├─ Back Panel (cut parts)
  │   └─ Side Panels (cut parts)
  │
  ├─ Pocket Assembly (sub-assembly)
  │   ├─ Pocket Fabric
  │   └─ Pocket Lining
  │
  └─ Waistband Assembly (sub-assembly)
      ├─ Waistband Fabric
      ├─ Interfacing
      └─ Elastic
```

### 4. Regular BOM Review

Schedule quarterly BOM reviews:
- Verify all components still available
- Update costs
- Check scrap factors
- Identify substitution opportunities
- Consolidate similar components

---

## Common BOM Errors and How to Fix

### Error 1: Missing Components

**Symptom**: Production stops because component not in BOM

**Example**: Forgot to add plastic fastener for hangtag

**Fix**:
```xml
<!-- Add missing component -->
<ProductAssoc productId="FTM-PNT-32-NVY"
              productIdTo="FTM-FASTENER-PLASTIC-HANGTAG"
              productAssocTypeId="MANUF_COMPONENT"
              fromDate="2025-01-20"
              quantity="1"
              quantityUomId="ea">
</ProductAssoc>
```

### Error 2: Incorrect Quantities

**Symptom**: Material shortage or excess

**Example**: BOM says 1.5m fabric but actually need 1.8m

**Fix**: Update quantity and recalculate MRP

### Error 3: Wrong Scrap Factor

**Symptom**: Consistent material shortages or excess

**Fix**: Track actual usage, adjust scrap factor

### Error 4: Circular Dependencies

**Symptom**: Product A requires Product B, which requires Product A

**Prevention**: Use OFBiz service `searchDuplicatedAncestor` before saving BOM

---

## OFBiz Services for BOM Management

| Service | Purpose | Key Parameters |
|---------|---------|----------------|
| `createBOMAssoc` | Create component relationship | productId, productIdTo, quantity, scrapFactor |
| `updateBOMAssoc` | Modify existing component | Same as create, plus fromDate |
| `copyBOMAssocs` | Clone BOM to new product | productId, productIdToNew |
| `getBOMTree` | Retrieve complete BOM hierarchy | productId, bomType |
| `getManufacturingComponents` | Get all components for production | productId, quantity, facilityId |
| `updateLowLevelCode` | Calculate component depth | productId |

---

## Integration with Other Systems

### BOM → MRP
- MRP explodes BOM to calculate gross requirements
- Compares with current inventory
- Generates net requirements
- Creates purchase requisitions

### BOM → Costing
- Calculate material cost per unit
- Roll up component costs
- Include scrap in cost calculation
- Support standard costing and actual costing

### BOM → Production
- Issue materials based on BOM
- Track consumption
- Report scrap and yield
- Update inventory

---

## Summary

**Key Takeaways**:

1. **BOM is the foundation** - Everything in manufacturing depends on accurate BOM
2. **Include ALL components** - From fabric to packaging to thread
3. **Account for waste** - Use realistic scrap factors
4. **Keep updated** - Regular reviews and adjustments
5. **Version control** - Use date ranges for changes
6. **Test in pilot** - Validate BOM with small production runs

**BOM Quality = Production Success**

A well-maintained BOM ensures:
- Accurate material requirements
- Correct purchasing
- Realistic cost calculation
- Smooth production flow
- Proper inventory tracking

---

**Document Version**: 1.0
**Last Updated**: 2025-12-18
**Related Documents**:
- OFBIZ-LEARNING-GUIDE.md
- FTM-GARMENTS-WORKFLOW-DATASET.md
- ERP-MANUFACTURING-GLOSSARY.md
