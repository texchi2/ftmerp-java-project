# Make-to-Order (MTO) Workflow for FTM Garments

Step-by-step guide to creating sales orders and production runs for products with no inventory.

---

## Problem

When trying to add `FTM-PNT-32-NVY` (Men's Casual Pant) to cart in e-commerce:
```
"Sorry we don't have enough of the product in stock, not adding to the cart"
```

This happens because:
1. Product has `requireInventory="Y"` (default)
2. No inventory exists (ATP = 0)
3. E-commerce frontend enforces strict inventory checks

---

## Solution: Two Approaches

### Approach 1: Configure Product for Make-to-Order (Recommended)

### Approach 2: Use Order Manager (Bypasses Inventory Checks)

---

## Approach 1: Configure Product for Make-to-Order

### Step 1: Disable Inventory Requirement

Navigate to: **Catalog → Products → Product Summary**

1. Login to WebTools: http://192.168.2.110:8080/webtools (admin/ofbiz)
2. Go to **Catalog** → **Products** → **Product Summary**
3. Search for product ID: `FTM-PNT-32-NVY`
4. Click on the product to open details
5. Click **Update Product**
6. Find the field: **Require Inventory**
7. Change from `Y` to `N`
8. Click **Update**

**What this does**: Allows ordering the product even when ATP (Available To Promise) is zero.

### Step 2: Verify Product Configuration

Check these fields are set correctly:

| Field | Value | Purpose |
|-------|-------|---------|
| `requireInventory` | `N` | Allow ordering without stock |
| `isVirtual` | `N` | Not a virtual product |
| `isVariant` | `N` | Not a variant |
| `productTypeId` | `FINISHED_GOOD` | Finished product |
| `billOfMaterialLevel` | `0` | Top-level product in BOM |

### Step 3: Try E-commerce Again

1. Go to e-commerce storefront
2. Search for `FTM-PNT-32-NVY`
3. Add to cart
4. Should now succeed!

---

## Approach 2: Create Order via Order Manager

If you want to keep `requireInventory="Y"` for inventory control, create orders through Order Manager which has more flexibility.

### Step 1: Access Order Manager

Navigate to: **Order Manager**

1. Login to WebTools: http://192.168.2.110:8080/webtools
2. Click **Order Manager** from main menu
3. Or direct URL: http://192.168.2.110:8080/ordermgr

### Step 2: Create New Sales Order

1. Click **Create New** → **Sales Order**
2. Fill in customer information:
   - **Party ID**: DemoCustomer (or create new customer)
   - **Currency**: USD
   - **Product Store**: (select your store, or leave default)
3. Click **Continue**

### Step 3: Add Order Items

1. In the order entry screen, find **Add Item** section
2. Enter:
   - **Product ID**: `FTM-PNT-32-NVY`
   - **Quantity**: 10 (or desired quantity)
   - **Unit Price**: 37.02 (or let system calculate from ProductPrice)
3. Click **Add Item**

**Note**: Order Manager allows adding items even with zero inventory if proper permissions exist.

### Step 4: Review and Submit Order

1. Review order details:
   - Line items
   - Quantities
   - Prices
   - Shipping method
   - Payment method
2. Click **Submit Order**
3. Note the **Order ID** (e.g., `WSCO10000`)

---

## Step 5: Create Production Run from Sales Order

Now that you have a sales order for products you don't have in stock, create a production run to manufacture them.

### Navigate to Manufacturing

1. Go to **Manufacturing** application
2. Or direct URL: http://192.168.2.110:8080/manufacturing

### Create Production Run

1. Click **Production Run** → **Create New**
2. Fill in:
   - **Product**: `FTM-PNT-32-NVY`
   - **Quantity**: 10 (match sales order quantity)
   - **Start Date**: Today or desired start date
   - **Routing**: (leave default or select if you have routing configured)
   - **Warehouse**: Your production facility
3. Click **Create**

### What Happens

OFBiz will:
1. **Explode the BOM** - Calculate material requirements from ProductAssoc
2. **Create material requirements** for all 18 components:
   - FTM-FAB-CTN-NVY (2.07 yards)
   - FTM-FAB-PLY-PKT (0.25 yards)
   - FTM-ZIP-7IN (1 piece)
   - FTM-BTN-BRS-20MM (1 piece)
   - FTM-RVT-10MM (4 pieces)
   - ... and 13 more components
3. **Generate Material Requirements** report
4. **Create tasks** for production routing (if configured)

### View Material Requirements

1. In the Production Run screen, click **Materials**
2. You'll see required quantities for each BOM component
3. Click **Issue Materials** when materials are available
4. Complete production tasks
5. Click **Complete Production Run**

---

## Step 6: Verify BOM Explosion

### Check Material Requirements via MRP

1. Go to **Manufacturing** → **MRP**
2. Run MRP for product `FTM-PNT-32-NVY`
3. View the generated requirements:

```
Production Run: PR10001
Product: FTM-PNT-32-NVY
Quantity: 10

Required Materials:
├─ FTM-FAB-CTN-NVY: 20.7 yards (2.07 × 10)
├─ FTM-FAB-PLY-PKT: 2.5 yards (0.25 × 10)
├─ FTM-ZIP-7IN: 10 pieces (1 × 10)
├─ FTM-BTN-BRS-20MM: 10 pieces (1 × 10)
├─ FTM-RVT-10MM: 40 pieces (4 × 10)
└─ ... (13 more components)
```

### Generate Purchase Orders

If materials are not in stock:
1. MRP will generate **planned purchase orders**
2. Review purchase requirements
3. Convert to actual purchase orders
4. Send to suppliers

---

## Complete Make-to-Order Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ 1. SALES ORDER                                              │
│    Customer orders 10 pants (FTM-PNT-32-NVY)               │
│    ATP = 0 (no inventory)                                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. PRODUCTION RUN CREATED                                   │
│    Manufacturing creates PR for 10 pants                    │
│    Start Date: 2025-12-30                                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. BOM EXPLOSION                                            │
│    OFBiz reads ProductAssoc for FTM-PNT-32-NVY             │
│    Calculates material requirements:                        │
│    - Fabric: 20.7 yards                                     │
│    - Zippers: 10 pieces                                     │
│    - Buttons: 10 pieces                                     │
│    - Rivets: 40 pieces                                      │
│    - Thread, labels, packaging, etc.                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. MRP RUNS                                                 │
│    Checks inventory for each component                      │
│    If insufficient → Create planned purchase orders         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. PURCHASE ORDERS                                          │
│    Send PO to suppliers for needed materials                │
│    Receive materials into warehouse                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. ISSUE MATERIALS                                          │
│    Issue materials from warehouse to production floor       │
│    Materials allocated to Production Run PR10001            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 7. PRODUCTION TASKS                                         │
│    - Cutting                                                │
│    - Sewing                                                 │
│    - Finishing                                              │
│    - Quality Control                                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 8. COMPLETE PRODUCTION RUN                                  │
│    10 finished pants produced                               │
│    Inventory updated: ATP = 10                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 9. FULFILL SALES ORDER                                      │
│    Pick 10 pants from finished goods                        │
│    Pack and ship to customer                                │
│    ATP = 0 again                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Reference Commands

### Check Product ATP (Available To Promise)

```sql
-- Via Entity Engine in WebTools
SELECT PRODUCT_ID, ATP_QTY, QOH_QTY
FROM PRODUCT_FACILITY
WHERE PRODUCT_ID = 'FTM-PNT-32-NVY';
```

### Check BOM Components

```sql
-- Via Entity Engine in WebTools
SELECT PRODUCT_ID, PRODUCT_ID_TO, QUANTITY, SCRAP_FACTOR
FROM PRODUCT_ASSOC
WHERE PRODUCT_ID = 'FTM-PNT-32-NVY'
  AND PRODUCT_ASSOC_TYPE_ID = 'MANUF_COMPONENT';
```

Expected result: 18 component associations

---

## Troubleshooting

### Issue: "Product not found"

**Cause**: Product ID misspelled or not loaded
**Solution**: Verify in WebTools → Entity Data Maintenance → Product

### Issue: "BOM not exploding"

**Cause**: ProductAssoc entries missing or wrong type
**Solution**:
```sql
SELECT * FROM PRODUCT_ASSOC
WHERE PRODUCT_ID = 'FTM-PNT-32-NVY';
```
Should return 18 rows with `PRODUCT_ASSOC_TYPE_ID = 'MANUF_COMPONENT'`

### Issue: "Cannot create production run"

**Cause**: Missing facility or routing
**Solution**:
1. Create a facility first (Facility Manager)
2. Routing is optional for basic production runs

### Issue: "Materials not reserved"

**Cause**: Insufficient inventory of raw materials
**Solution**: Run MRP to generate purchase requirements

---

## Summary

**For Development/Testing** (Zero Inventory):
1. Set `requireInventory="N"` on product
2. Create sales order via e-commerce or Order Manager
3. Create production run manually
4. Complete production to create inventory

**For Production** (Proper MRP):
1. Keep `requireInventory="Y"`
2. Create sales orders via Order Manager
3. Run MRP to calculate requirements
4. Generate purchase orders for materials
5. Create production runs when materials available
6. Complete production and fulfill orders

---

## Next Steps

1. ✓ Load BOM data (completed)
2. Configure product for MTO
3. Create test sales order
4. Create production run
5. Verify BOM explosion
6. Issue materials
7. Complete production
8. Fulfill order

See also:
- [BOM-DEEP-DIVE.md](./BOM-DEEP-DIVE.md) - BOM structure details
- [OFBIZ-LEARNING-GUIDE.md](./OFBIZ-LEARNING-GUIDE.md) - General OFBiz concepts
- [FTM-GARMENTS-WORKFLOW-DATASET.md](./FTM-GARMENTS-WORKFLOW-DATASET.md) - Complete workflows
