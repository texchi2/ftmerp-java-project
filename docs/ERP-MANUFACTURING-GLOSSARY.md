# FTM ERP Manufacturing and ERP Glossary
# 製造與企業資源規劃術語表

A comprehensive glossary of manufacturing and ERP terms with English-Chinese translations and detailed explanations for the FTM Garments ERP system.

---

## Supply Chain Roles (供應鏈角色)

### Supplier (供應商)
**Definition**: A Supplier provides raw materials, components, or goods to manufacturers or businesses for production or resale.

**Characteristics**:
- Typically at the start of the supply chain
- Operates in B2B (Business-to-Business) settings
- Deals in bulk quantities under long-term contracts
- May specialize in specific materials or components

**Example in Garment Manufacturing**:
- Cotton fabric supplier
- Button and zipper supplier
- Thread manufacturer
- Dye and chemical supplier

**OFBiz Entity**: `Party` with role `SUPPLIER`, linked via `SupplierProduct`

---

### Manufacturer (製造商)
**Definition**: Transforms raw materials into finished goods. May also act as a supplier to distributors.

**Characteristics**:
- Converts raw materials through production processes
- Has production facilities (factories, workshops)
- Manages BOM (Bill of Materials) and production routing
- Quality control and production scheduling

**Example**: FTM Garments (you!)
- Purchases fabric, buttons, thread
- Manufactures shirts, pants, dresses
- Sells to distributors or retailers

**OFBiz Entities**: `WorkEffort` (production runs), `InventoryItem`, `ProductAssoc` (BOM)

---

### Distributor / Wholesaler (經銷商 / 大盤商)
**Definition**: Purchases finished goods in bulk from manufacturers and resells to retailers or other businesses.

**Types**:
1. **Authorized Distributor (授權經銷商)**: Official partnership with manufacturer
2. **Sole Distributor (獨家經銷商)**: Exclusive rights in a region
3. **Sub-distributor (中盤商)**: Buys from main distributor

**Characteristics**:
- Warehouses inventory
- Provides logistics and distribution
- B2B focus
- May provide financing to retailers
- Handles bulk orders

**Revenue Model**: Profit from price difference (buy wholesale, sell to retailers)

**OFBiz Entity**: `Party` with role `DISTRIBUTOR`, `OrderHeader` with type `SALES_ORDER`

---

### Agent (代理商)
**Definition**: Represents the manufacturer or distributor without taking ownership of goods.

**Types**:
1. **General Agent (總代理)**: Broad authority to represent
2. **Sole Agent (獨家代理)**: Exclusive representation rights

**Characteristics**:
- Does NOT own inventory
- Earns **commission** on sales
- Facilitates deals between buyers and sellers
- Provides market intelligence and customer relationships

**Revenue Model**: Commission-based (percentage of sales)

**Difference from Distributor**:
- Agent: No inventory ownership, commission-based
- Distributor: Owns inventory, profit from resale

---

### Vendor (供應商/賣方)
**Definition**: General term for any entity that sells goods or services. Can refer to suppliers, distributors, or service providers.

**Usage Context**:
- In **purchasing context**: Vendor = Supplier (who we buy from)
- In **sales context**: We are the vendor to our customers
- Flexible term depending on perspective

**OFBiz**: Used generically in various contexts

---

### Retailer (零售商)
**Definition**: Sells finished goods directly to end consumers (B2C).

**Characteristics**:
- Customer-facing (shops, e-commerce)
- Small quantity transactions
- Focus on customer service, pricing, availability
- At the end of the supply chain

**Example**:
- ABC Retail Store (customer in our workflow example)
- Clothing boutique
- Department store
- Online shop

**OFBiz Entity**: `Party` with role `CUSTOMER`, `OrderHeader` with type `SALES_ORDER`

---

### Consumer (消費者)
**Definition**: End user who purchases goods for personal use (not for resale).

**Characteristics**:
- Final point in supply chain
- B2C transactions
- Individual purchases
- No resale intent

---

## Supply Chain Flow (供應鏈流程)

```
Raw Material Supplier → Manufacturer → Distributor → Retailer → Consumer
  (Cotton Mill)      →  (FTM Garments) → (Wholesaler) → (Shop) → (Customer)

Alternative with Agent:
Raw Material Supplier → Manufacturer → Agent → Retailer → Consumer
                                        ↓
                                   (Commission)
```

---

## Accounting Terms (會計術語)

### Accounts Payable (應付賬款) - AP
**Definition**: Money owed by the company to suppliers or creditors.

**When it occurs**:
- Purchase raw materials on credit
- Receive services but haven't paid yet
- Utility bills not yet paid

**Example**: FTM buys fabric on Net 30 terms → Accounts Payable created

**OFBiz Entity**: `InvoiceHeader` with type `PURCHASE_INVOICE`, status `INVOICE_READY`

**Balance Sheet**: Current Liability

---

### Accounts Payable Invoice (應付賬款發票)
**Definition**: Bill received from supplier for goods or services purchased on credit.

**Workflow**:
1. Purchase Order created
2. Goods received
3. Invoice received from supplier → AP Invoice
4. Payment made → AP reduced

---

### Accounts Receivable (應收賬款) - AR
**Definition**: Money owed to the company by customers.

**When it occurs**:
- Sold goods on credit
- Services provided, payment pending
- Shipped goods, awaiting payment

**Example**: ABC Retail buys 500 shirts on Net 30 → Accounts Receivable created

**OFBiz Entity**: `InvoiceHeader` with type `SALES_INVOICE`, status `INVOICE_READY`

**Balance Sheet**: Current Asset

---

### Accounts Receivable Invoice (應收賬款發票)
**Definition**: Bill sent to customer for goods or services sold on credit.

**Workflow**:
1. Sales Order approved
2. Goods shipped
3. Invoice sent to customer → AR Invoice
4. Payment received → AR reduced

---

### Debtor (債務人)
**Definition**: Party that owes money.

**Business Context**: Customer who purchased on credit

**Example**: ABC Retail is a debtor to FTM Garments (owes $15,000 for shirt order)

**Note**: You are a debtor when using a credit card (owe bank)

**OFBiz**: Customer with outstanding `InvoiceHeader` (SALES_INVOICE, unpaid)

---

### Creditor (債權人)
**Definition**: Party to whom money is owed.

**Business Context**: Supplier who provided goods/services on credit

**Example**: Cotton supplier is a creditor to FTM Garments (owed $5,000 for fabric)

**Balance Sheet**: Creditors appear as **Current Liabilities**

**OFBiz**: Supplier with outstanding `InvoiceHeader` (PURCHASE_INVOICE, unpaid)

---

### Debit (借方)
**Definition**: Accounting entry that increases assets or expenses, decreases liabilities or equity.

**Double Entry Rule**:
- Debit = Left side
- Assets ↑, Expenses ↑
- Liabilities ↓, Equity ↓, Revenue ↓

**Example**:
```
Purchase fabric for cash:
  Debit: Raw Materials Inventory (Asset ↑)
  Credit: Cash (Asset ↓)
```

---

### Credit (貸方)
**Definition**: Accounting entry that increases liabilities, equity, or revenue; decreases assets or expenses.

**Double Entry Rule**:
- Credit = Right side
- Liabilities ↑, Equity ↑, Revenue ↑
- Assets ↓, Expenses ↓

**Example**:
```
Sell shirts on credit:
  Debit: Accounts Receivable (Asset ↑)
  Credit: Sales Revenue (Revenue ↑)
```

---

### Accrual Based Accounting (應計基礎會計)
**Definition**: Records revenue when earned and expenses when incurred, regardless of cash flow.

**Example**:
- Sell goods in January, payment in March → Record revenue in January
- Receive fabric in February, pay in April → Record expense in February

**OFBiz Default**: Uses accrual accounting

**Advantage**: Matches revenue with related expenses (matching principle)

---

### Cash Based Accounting (現金基礎會計)
**Definition**: Records transactions only when cash changes hands.

**Example**:
- Sell goods in January, payment in March → Record revenue in March
- Receive fabric in February, pay in April → Record expense in April

**Advantage**: Simpler, shows actual cash position

**Disadvantage**: Doesn't match revenue with expenses

---

### Chart of Accounts (會計科目表) - COA
**Definition**: Complete list of all general ledger accounts used by the organization.

**Structure**:
```
1000-1999: Assets (資產)
  1100: Cash (現金)
  1200: Accounts Receivable (應收賬款)
  1300: Inventory (存貨)
  1400: Fixed Assets (固定資產)

2000-2999: Liabilities (負債)
  2100: Accounts Payable (應付賬款)
  2200: Loans (貸款)

3000-3999: Equity (權益)
  3100: Owner's Equity (所有者權益)
  3200: Retained Earnings (留存收益)

4000-4999: Revenue (收入)
  4100: Sales Revenue (銷售收入)

5000-5999: Cost of Goods Sold (銷售成本)
  5100: Material Costs (材料成本)
  5200: Labor Costs (人工成本)

6000-6999: Expenses (費用)
  6100: Salaries (工資)
  6200: Rent (租金)
  6300: Utilities (水電)
```

**OFBiz Entity**: `GlAccount`

---

### General Ledger (總賬) - GL
**Definition**: Central accounting record containing all financial transactions.

**Structure**: All debits and credits posted to GL accounts

**OFBiz Entity**: `GlAccount`, `AcctgTrans`, `AcctgTransEntry`

---

### Journal Entry (會計分錄)
**Definition**: Record of a financial transaction with debits and credits.

**Format**:
```
Date: 2025-01-15
Description: Purchase fabric on credit

  Debit: Raw Materials Inventory    $5,000
  Credit: Accounts Payable                  $5,000
```

**OFBiz Entity**: `AcctgTrans` with multiple `AcctgTransEntry` records

---

### Double Entry Accounting (複式記賬法)
**Definition**: Every transaction affects at least two accounts (debit and credit must equal).

**Fundamental Equation**:
```
Assets = Liabilities + Equity
```

**Example**:
```
Purchase machinery for $10,000 cash:
  Debit: Machinery (Asset) +$10,000
  Credit: Cash (Asset) -$10,000

Total debits = Total credits = $10,000 ✓
```

---

### Balance Sheet (資產負債表)
**Definition**: Financial statement showing assets, liabilities, and equity at a specific point in time.

**Structure**:
```
BALANCE SHEET - FTM Garments
As of December 31, 2025

ASSETS
  Current Assets:
    Cash                           $50,000
    Accounts Receivable            $80,000
    Inventory                     $120,000
    ─────────────────────────────────────
    Total Current Assets          $250,000

  Fixed Assets:
    Machinery                     $200,000
    Less: Accumulated Depreciation ($40,000)
    ─────────────────────────────────────
    Net Fixed Assets              $160,000

  TOTAL ASSETS                    $410,000

LIABILITIES
  Current Liabilities:
    Accounts Payable               $60,000
    Short-term Loans               $30,000
    ─────────────────────────────────────
    Total Current Liabilities      $90,000

  Long-term Liabilities:
    Long-term Loans               $100,000
    ─────────────────────────────────────
    TOTAL LIABILITIES             $190,000

EQUITY
  Owner's Capital                 $150,000
  Retained Earnings                $70,000
    ─────────────────────────────────────
    TOTAL EQUITY                  $220,000

TOTAL LIABILITIES + EQUITY        $410,000
```

**Equation**: Assets = Liabilities + Equity

---

### Income Statement (損益表) / Profit & Loss Statement (P&L)
**Definition**: Financial statement showing revenue, expenses, and profit over a period.

**Structure**:
```
INCOME STATEMENT - FTM Garments
For Year Ended December 31, 2025

REVENUE
  Sales Revenue                   $500,000

COST OF GOODS SOLD
  Material Costs                  $180,000
  Labor Costs                      $80,000
  Manufacturing Overhead           $40,000
  ─────────────────────────────────────
  Total COGS                      $300,000

GROSS PROFIT                      $200,000

OPERATING EXPENSES
  Salaries & Wages                 $60,000
  Rent                             $24,000
  Utilities                        $12,000
  Marketing                        $20,000
  Depreciation                     $10,000
  ─────────────────────────────────────
  Total Operating Expenses        $126,000

NET INCOME                         $74,000
```

---

### Assets (資產)
**Definition**: Resources owned by the company with economic value.

**Types**:

1. **Current Assets (流動資產)**: Convertible to cash within 1 year
   - Cash
   - Accounts Receivable
   - Inventory
   - Prepaid Expenses

2. **Fixed Assets (固定資產)**: Long-term physical assets
   - Machinery
   - Buildings
   - Vehicles
   - Equipment

3. **Intangible Assets (無形資產)**: Non-physical assets
   - Patents
   - Trademarks
   - Goodwill
   - Software

---

### Liabilities (負債)
**Definition**: Obligations owed to external parties.

**Types**:

1. **Current Liabilities (流動負債)**: Due within 1 year
   - Accounts Payable
   - Short-term Loans
   - Wages Payable
   - Taxes Payable

2. **Long-term Liabilities (長期負債)**: Due after 1 year
   - Long-term Loans
   - Bonds Payable
   - Mortgage

---

### Equity (權益) / Capital (資本)
**Definition**: Owner's residual interest in assets after deducting liabilities.

**Components**:
- Owner's Capital (投入資本)
- Retained Earnings (留存收益)
- Common Stock (普通股)

**Equation**: Equity = Assets - Liabilities

---

### Retained Earnings (留存收益)
**Definition**: Cumulative net income retained in the business (not distributed to owners).

**Calculation**:
```
Beginning Retained Earnings
+ Net Income (or - Net Loss)
- Dividends Paid
= Ending Retained Earnings
```

---

### Depreciation (折舊)
**Definition**: Systematic allocation of asset cost over its useful life.

**Example**:
```
Sewing machine cost: $10,000
Useful life: 5 years
Annual depreciation: $10,000 / 5 = $2,000/year

Journal Entry:
  Debit: Depreciation Expense     $2,000
  Credit: Accumulated Depreciation       $2,000
```

---

### Cost of Goods Sold (銷售成本) - COGS
**Definition**: Direct costs of producing goods sold.

**Components**:
- Material costs
- Direct labor
- Manufacturing overhead

**Formula**:
```
Beginning Inventory
+ Purchases (or Production)
- Ending Inventory
= Cost of Goods Sold
```

---

### Trial Balance (試算表)
**Definition**: List of all GL account balances to verify debits = credits.

**Purpose**: Check for posting errors before preparing financial statements

---

### Budget (預算)
**Definition**: Financial plan for a specific period.

**Types**:
- Operating Budget (營運預算)
- Capital Budget (資本預算)
- Cash Budget (現金預算)

**OFBiz Entity**: `Budget`, `BudgetItem`, `BudgetRole`

---

## Manufacturing Terms (製造業術語)

### Bill of Materials (物料清單) - BOM
**Definition**: Complete list of raw materials, components, and quantities needed to manufacture a product.

**Example**: Men's Casual Pant BOM (see detailed example in OFBIZ-LEARNING-GUIDE.md)

**OFBiz Entity**: `ProductAssoc` with type `MANUF_COMPONENT`

---

### Material Requirements Planning (物料需求規劃) - MRP
**Definition**: System to calculate material requirements based on production schedule and current inventory.

**Process**:
1. Analyze sales orders (demand)
2. Explode BOM
3. Check inventory
4. Calculate net requirements
5. Generate purchase orders or production orders

**OFBiz Entity**: `MrpEvent`

---

### Work in Progress (在製品) - WIP
**Definition**: Partially completed goods in production process.

**Example**: Cut fabric not yet sewn, sewn shirts not yet packed

**OFBiz**: `InventoryItem` with type `WIP_INVENTORY`

---

### Inventory (存貨) / Stock (庫存)
**Definition**: Goods held for sale or production.

**Types**:
1. **Raw Materials (原材料)**: Fabric, buttons, thread
2. **Work in Progress (在製品)**: Partially completed goods
3. **Finished Goods (成品)**: Ready for sale

**OFBiz Entity**: `InventoryItem`

---

### Production Run (生產工單)
**Definition**: Order to manufacture specific quantity of product.

**OFBiz Entity**: `WorkEffort` with type `PROD_ORDER_HEADER`

---

### Routing (工藝路線)
**Definition**: Sequence of operations to manufacture a product.

**Example for Shirt**:
1. Cutting
2. Sewing
3. Quality Control
4. Ironing
5. Packing

**OFBiz Entity**: `WorkEffort` with type `ROUTING`

---

### Lead Time (前置時間)
**Definition**: Time between order placement and receipt.

**Types**:
- **Supplier Lead Time**: Time to receive from supplier
- **Production Lead Time**: Time to manufacture
- **Delivery Lead Time**: Time to ship to customer

---

### Capacity (產能)
**Definition**: Maximum output a facility can produce.

**Measured by**: Units per day, hours available, machine capacity

**OFBiz Entity**: `TechDataCalendar`

---

### Scrap Factor (損耗率)
**Definition**: Percentage of material expected to be wasted.

**Example**: Cutting fabric scrap factor = 15% (need 1.15m to get 1m usable)

**OFBiz Field**: `ProductAssoc.scrapFactor`

---

## ERP and Business Terms

### ERP (Enterprise Resource Planning) - 企業資源規劃
**Definition**: Integrated software system managing all business processes.

**Modules**:
- Accounting
- Order Management
- Manufacturing
- Inventory
- Human Resources
- CRM

---

### CRM (Customer Relationship Management) - 客戶關係管理
**Definition**: System to manage customer interactions and data.

**OFBiz Module**: `SFA` (Sales Force Automation)

---

### SCM (Supply Chain Management) - 供應鏈管理
**Definition**: Management of flow of goods and services from supplier to customer.

---

### E-Commerce (電子商務) / E-Business
**Definition**: Buying and selling goods online.

**OFBiz Module**: `ecommerce` application

---

### Fulfillment (履約)
**Definition**: Process of receiving, processing, and delivering orders to customers.

**Steps**:
1. Order received
2. Pick items from warehouse
3. Pack
4. Ship
5. Deliver

---

### CMMS/EAM (Computerized Maintenance Management System / Enterprise Asset Management)
**Definition**: System to manage maintenance of equipment and assets.

**OFBiz Module**: `AssetMaint`

---

## Human Resources Terms

### Party (當事人)
**Definition**: Generic term for person or organization.

**Types**:
- Person (個人)
- Party Group (組織)

**OFBiz Entity**: `Party`

---

### Employee (員工)
**Definition**: Person employed by the organization.

**OFBiz**: `Party` with role `EMPLOYEE`

---

### Employment (僱用)
**Definition**: Relationship between employer and employee.

**OFBiz Entity**: `Employment`

---

### Position (職位)
**Definition**: Job role in organizational structure.

**Types**: Manager, Supervisor, Operator, Quality Inspector

**OFBiz Entity**: `EmplPosition`

---

### Termination (終止)
**Definition**: End of employment relationship.

**Types**:
- Resignation (辭職)
- Dismissal (解僱)
- Retirement (退休)

**OFBiz Field**: `Employment.terminationReasonId`, `terminationTypeId`

---

### Security Group (安全群組)
**Definition**: Set of permissions assigned to users.

**Example**: ACCOUNTING_ADMIN, MANUFACTURING_USER

**OFBiz Entity**: `SecurityGroup`

---

### Responsibility (責任)
**Definition**: Areas of authority and tasks assigned to a position or employee.

---

## Agreement Terms (協議術語)

### Agreement (協議)
**Definition**: Formal arrangement between parties.

**Types**:
- Sales Agreement (銷售協議)
- Purchase Agreement (採購協議)
- Commission Agreement (傭金協議)

**OFBiz Entity**: `Agreement`

---

### Invoice Date (發票日期)
**Definition**: Date invoice was issued.

---

### Invoice Due Date (發票到期日)
**Definition**: Date payment is due.

**Example**: Invoice Date: Jan 1, Terms: Net 30 → Due Date: Jan 31

---

## Additional Terms

### Entity (實體)
**Definition**: Data structure in OFBiz representing a business concept.

**Examples**: `OrderHeader`, `Product`, `Party`

---

### Component (組件)
**Definition**: Modular part of OFBiz system.

**Examples**: `order`, `manufacturing`, `product`, `accounting`

---

### Application (應用)
**Definition**: Business module in OFBiz.

**Location**: `/applications/` directory

---

### End of Year Rollover (年度結轉)
**Definition**: Process of closing accounting year and transferring balances to new year.

**Steps**:
1. Close revenue and expense accounts
2. Transfer net income to Retained Earnings
3. Start new fiscal year

---

## Quick Reference Charts

### Asset vs Liability vs Equity

| Type | Debit | Credit | Examples |
|------|-------|--------|----------|
| Assets | Increase | Decrease | Cash, Inventory, Equipment |
| Liabilities | Decrease | Increase | AP, Loans, Wages Payable |
| Equity | Decrease | Increase | Capital, Retained Earnings |
| Revenue | Decrease | Increase | Sales, Service Revenue |
| Expenses | Increase | Decrease | Salaries, Rent, Utilities |

---

### Debtor vs Creditor

| Perspective | You Are | Other Party Is | Account Type |
|-------------|---------|----------------|--------------|
| You buy on credit | Debtor | Creditor | Accounts Payable (Liability) |
| You sell on credit | Creditor | Debtor | Accounts Receivable (Asset) |
| You use credit card | Debtor | Bank (Creditor) | Credit Card Payable |
| You have bank savings | Creditor | Bank (Debtor) | Bank holds your money |

---

### Supplier vs Distributor vs Agent vs Vendor

| Role | Owns Goods? | Revenue Model | Typical Customer |
|------|-------------|---------------|------------------|
| Supplier | Yes | Profit from sale | Manufacturers |
| Manufacturer | Yes (produces) | Profit from sale | Distributors, Retailers |
| Distributor | Yes | Profit from markup | Retailers |
| Agent | No | Commission | Varies |
| Vendor | Context-dependent | Varies | End customer or business |
| Retailer | Yes | Profit from markup | Consumers |

---

## Accounting Equation Reference

**Fundamental Equation**:
```
Assets = Liabilities + Equity
```

**Expanded Equation**:
```
Assets = Liabilities + (Capital + Retained Earnings + Revenue - Expenses)
```

**Double Entry Rule**:
```
Total Debits = Total Credits (always balanced)
```

---

## Financial Statement Relationships

```
Balance Sheet (Period End Snapshot)
    ↓ feeds
Income Statement (Period Activity)
    ↓ Net Income flows to
Retained Earnings (Balance Sheet)
    ↓
Cash Flow Statement (Cash movements)
```

---

**Document Version**: 1.0
**Last Updated**: 2025-12-18
**Purpose**: Reference guide for FTM IT team learning OFBiz ERP system
**Language**: English with Chinese translations (繁體中文)
