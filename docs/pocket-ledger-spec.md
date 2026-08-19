# পকেটখাতা (Pocket Ledger) — Technical Handoff Spec

এই ডকুমেন্টটা `PocketLedger.jsx` প্রোটোটাইপের সাথে দেওয়ার জন্য। JSX ফাইলটা UI/UX আর ফ্লো দেখায়; এই ডকুমেন্ট সেটার পেছনের ডাটা মডেল, বিজনেস লজিক, আর API কনট্রাক্ট বর্ণনা করে। টার্গেট স্ট্যাক: **Flutter (frontend) + Spring Boot (backend) + Supabase PostgreSQL (database, optionally Supabase Auth)**।

---

## 1. Core business rules (সবচেয়ে গুরুত্বপূর্ণ অংশ)

1. **Pocket balance** সবসময় সরল হিসাব: `pocket_balance = SUM(income transactions) - SUM(expense transactions)`. এর বাইরে আলাদা কোনো অ্যাডজাস্টমেন্ট লাগবে না, কারণ loan-related টাকাও নিচের নিয়মে transaction হিসেবেই ঢুকে যায়।
2. **কাউকে ধার দিলে (lent)** → সাথে সাথে একটা `expense` টাইপ transaction তৈরি হয় (category: `loan_given`), amount = loan amount, date = loan দেওয়ার তারিখ।
3. **ধার ফেরত পেলে (repayment received on a lent loan)** → একটা `income` টাইপ transaction তৈরি হয় (category: `loan_repay_income`), amount = যত টাকা ফেরত পেলাম, date = ফেরত পাওয়ার তারিখ (loan দেওয়ার তারিখ না, পেমেন্টের তারিখ)।
4. **কারো থেকে ধার নিলে (borrowed)** → একটা `income` টাইপ transaction তৈরি হয় (category: `loan_taken`), amount = loan amount, date = ধার নেওয়ার তারিখ।
5. **ধার শোধ করলে (repayment made on a borrowed loan)** → একটা `expense` টাইপ transaction তৈরি হয় (category: `loan_repay_expense`), amount = যত টাকা শোধ করলাম, date = শোধ করার তারিখ।
6. প্রতিটা payment একটা `loans.paid_amount` কে ইনক্রিমেন্ট করে (cap: `paid_amount <= amount`), আর একইসাথে একটা linked transaction তৈরি করে (`transactions.linked_loan_id` দিয়ে জোড়া লাগানো)। এই দুটো action **একটা DB transaction/অ্যাটমিক অপারেশনে** হওয়া উচিত।
7. Loan-এর `due_amount = amount - paid_amount`. `due_amount = 0` হলে status `paid`, নাহলে `due`।
8. Loans পেজে হেডলাইন হিসেবে দেখানো হয়: `total_lent = SUM(amount) WHERE type='lent'`, `total_borrowed = SUM(amount) WHERE type='borrowed'`, আর পাশে কত এখনো due তাও।

---

## 2. PostgreSQL schema (Supabase)

```sql
-- Users table (Supabase Auth ব্যবহার করলে auth.users থাকবেই; এক্সট্রা প্রোফাইল দরকার হলে):
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  display_name text,
  created_at timestamptz default now()
);

-- Categories: seed data হিসেবে ইনসার্ট, ইউজার-এডিটেবল না (এখনকার জন্য)
create table public.categories (
  id text primary key,              -- 'food','rent','loan_given', etc.
  kind text not null check (kind in ('expense','income')),
  label_bn text not null,
  label_en text not null,
  icon text not null,               -- icon name string, Flutter side এ map করা হবে
  color text not null,              -- hex color
  is_system boolean default false   -- true হলে loan-related auto categories (user delete করতে পারবে না)
);

create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('income','expense')),
  category_id text not null references public.categories(id),
  amount numeric(12,2) not null check (amount > 0),
  note text,
  txn_date date not null,
  linked_loan_id uuid references public.loans(id) on delete set null,
  created_at timestamptz default now()
);

create table public.loans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('lent','borrowed')),
  person_name text not null,
  amount numeric(12,2) not null check (amount > 0),
  paid_amount numeric(12,2) not null default 0 check (paid_amount >= 0),
  note text,
  loan_date date not null,
  due_date date,
  created_at timestamptz default now(),
  constraint paid_not_exceed check (paid_amount <= amount)
);

create table public.loan_payments (
  id uuid primary key default gen_random_uuid(),
  loan_id uuid not null references public.loans(id) on delete cascade,
  transaction_id uuid references public.transactions(id) on delete set null,
  amount numeric(12,2) not null check (amount > 0),
  payment_date date not null,
  created_at timestamptz default now()
);

create table public.plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_date date not null,
  text text not null,
  created_at timestamptz default now()
);

-- Row Level Security: প্রতিটা টেবিলে user শুধু নিজের ডেটা দেখবে/এডিট করবে
alter table public.transactions enable row level security;
alter table public.loans enable row level security;
alter table public.loan_payments enable row level security;
alter table public.plans enable row level security;

create policy "own rows only" on public.transactions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows only" on public.loans
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows only" on public.plans
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

**Seed categories** (JSX-এর `CATS` / `INCOME_CATS` অবজেক্ট থেকে):

| id | kind | label_bn | label_en | is_system |
|---|---|---|---|---|
| food | expense | খাবার | Food | false |
| rent | expense | বাসাভাড়া | Rent | false |
| transport | expense | যাতায়াত | Transport | false |
| bills | expense | বিল | Bills | false |
| shopping | expense | কেনাকাটা | Shopping | false |
| health | expense | স্বাস্থ্য | Health | false |
| education | expense | শিক্ষা | Education | false |
| other | expense | অন্যান্য | Other | false |
| loan_given | expense | ধার দেওয়া | Loan given | true |
| loan_repay_expense | expense | ধার শোধ করলাম | Loan repaid by me | true |
| salary | income | বেতন | Salary | false |
| business | income | ব্যবসা | Business | false |
| other_income | income | অন্যান্য আয় | Other income | false |
| loan_taken | income | ধার নেওয়া | Loan taken | true |
| loan_repay_income | income | ধার ফেরত পেলাম | Loan repaid to me | true |

---

## 3. Auth flow (JSX-এর login/signup/OTP/forgot-password স্ক্রিনগুলো)

Supabase Auth ব্যবহার করলে এই এন্ডপয়েন্টগুলো নিজেরাই লাগবে না — Supabase SDK দিয়ে সরাসরি:

- সাইনআপ: `supabase.auth.signInWithOtp({ email })` → ইউজার ইমেইলে ৬-ডিজিট কোড পায়
- OTP verify: `supabase.auth.verifyOtp({ email, token, type: 'email' })`
- পাসওয়ার্ড সেট (verify-এর পর): `supabase.auth.updateUser({ password })`
- লগইন: `supabase.auth.signInWithPassword({ email, password })`
- Forgot password: `supabase.auth.resetPasswordForEmail(email)` → রিসেট লিংক/OTP পাঠায়

Spring Boot layer শুধু Supabase JWT verify করে বাকি বিজনেস API গুলো protect করবে (`Authorization: Bearer <supabase_jwt>`)।

---

## 4. API endpoints (Spring Boot)

সব এন্ডপয়েন্ট JWT-protected, `user_id` টোকেন থেকে বের করা হবে (client থেকে পাঠানো লাগবে না)।

### Transactions
| Method | Path | Body / Query | কাজ |
|---|---|---|---|
| GET | `/api/transactions` | query: `type, categoryId, dateFrom, dateTo, amountMin, amountMax, search` | ফিল্টার সহ লিস্ট (JSX-এর advanced filter sheet এই প্যারামগুলোই পাঠাবে) |
| POST | `/api/transactions` | `{type, categoryId, amount, note, txnDate}` | নতুন transaction |
| DELETE | `/api/transactions/{id}` | — | ডিলিট |

### Loans
| Method | Path | Body | কাজ |
|---|---|---|---|
| GET | `/api/loans?type=lent\|borrowed&status=all\|due\|paid` | — | লিস্ট + total_lent/total_borrowed summary |
| POST | `/api/loans` | `{type, personName, amount, note, loanDate, dueDate}` | নতুন loan তৈরি + **অটোমেটিক linked transaction তৈরি** (rule #2, #4) |
| POST | `/api/loans/{id}/payments` | `{amount, paymentDate}` | পেমেন্ট রেকর্ড + `paid_amount` আপডেট + **অটোমেটিক linked transaction তৈরি** (rule #3, #5) — একটা `@Transactional` মেথডে করতে হবে |
| GET | `/api/loans/summary` | — | হোম পেজের stat card গুলোর জন্য: total due lent, total due borrowed |

### Reports
| Method | Path | কাজ |
|---|---|---|
| GET | `/api/reports/monthly-trend?months=6` | মাস-ভিত্তিক income/expense (bar chart) |
| GET | `/api/reports/category-breakdown?month=2026-08` | ক্যাটাগরি অনুযায়ী খরচ (pie chart) |

### Planner
| Method | Path | Body | কাজ |
|---|---|---|---|
| GET | `/api/plans` | — | সব প্ল্যান, তারিখ অনুযায়ী sorted |
| POST | `/api/plans` | `{planDate, text}` | নতুন প্ল্যান |
| DELETE | `/api/plans/{id}` | — | ডিলিট |

### Home dashboard (একটা aggregate endpoint, একাধিক API কল এড়াতে)
| Method | Path | রেসপন্স |
|---|---|---|
| GET | `/api/dashboard` | `{pocketBalance, totalIncome, totalExpense, totalLentDue, totalBorrowedDue, recentTransactions[4]}` |

---

## 5. Flutter সাইডে যা মাথায় রাখতে হবে

- **i18n**: JSX-এর `T` অবজেক্টে সব bn/en স্ট্রিং আছে — এগুলো `.arb` ফাইলে কনভার্ট করে Flutter-এর `intl` প্যাকেজ দিয়ে করা যাবে।
- **Category/loan payment এর সাথে transaction অটো-তৈরি হওয়া লজিকটা ব্যাকএন্ডে থাকা উচিত**, Flutter সাইডে না — যাতে অন্য কোনো ক্লায়েন্ট (future web app ইত্যাদি) থেকেও একই নিয়ম মানা হয়।
- Glassmorphism UI Flutter-এ `BackdropFilter` + `ImageFilter.blur` দিয়ে রেপ্লিকেট করা যায়।
- Loan card-এর প্রগ্রেস বার, gauge chart ইত্যাদির জন্য `fl_chart` প্যাকেজ ভালো অপশন (recharts-এর মতো ফিচার দেয়)।

---

## 6. এই স্পেকের বাইরে যা এখনো ঠিক করা হয়নি (তোমার AI-কে জিজ্ঞেস করাতে হবে বা তুমি ডিসাইড করবে)

- Currency শুধু ৳ (BDT) ধরা হয়েছে, multi-currency লাগলে আলাদা কলাম লাগবে।
- Recurring transactions (মাসিক ভাড়া/বেতন অটো-এন্ট্রি) — এখনো ডিজাইন করা হয়নি।
- Budget limits/alerts — এখনো ডিজাইন করা হয়নি।
- Multi-account/wallet (ক্যাশ vs ব্যাংক vs বিকাশ) — এখনো ডিজাইন করা হয়নি।
