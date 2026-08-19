import React, { useState, useMemo } from "react";
import {
  Home as HomeIcon,
  ArrowLeftRight,
  HandCoins,
  PieChart as PieIcon,
  Plus,
  X,
  UtensilsCrossed,
  Zap,
  Bus,
  ShoppingBag,
  HeartPulse,
  GraduationCap,
  MoreHorizontal,
  Briefcase,
  TrendingUp,
  Gift,
  ArrowUpRight,
  ArrowDownRight,
  Wallet,
  Mail,
  Lock,
  ShieldCheck,
  LogOut,
  Search,
  SlidersHorizontal,
  Languages,
  Menu,
  NotebookPen,
  Trash2,
  KeyRound,
  Sparkles,
  Wallet2,
  CircleDollarSign,
} from "lucide-react";
import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  Tooltip,
} from "recharts";

// ---------- glass palette ----------
const COLORS = {
  ink: "#241129",
  deepText: "#3B1E52",
  gold: "#E8B84B",
  goldSoft: "rgba(232,184,75,0.4)",
  coral: "#FF6F61",
  income: "#2FBF9F",
  expense: "#FF6F61",
  lent: "#E8B84B",
  borrow: "#6FA0E8",
  muted: "#6B5C78",
  mutedLight: "#DCCBE8",
  glass: "rgba(255,255,255,0.55)",
  glassBorder: "rgba(255,255,255,0.75)",
  glassDark: "rgba(35,16,54,0.5)",
  glassDarkBorder: "rgba(255,255,255,0.2)",
  glassInput: "rgba(255,255,255,0.7)",
};

// ---------- i18n ----------
const T = {
  appName: { bn: "পকেটখাতা", en: "Pocket Ledger" },
  inPocket: { bn: "পকেটে আছে", en: "In your pocket" },
  statIncome: { bn: "আয়", en: "Income" },
  statExpense: { bn: "খরচ", en: "Expense" },
  statLent: { bn: "ধার দিয়েছি (বাকি)", en: "Lent (due)" },
  statBorrowed: { bn: "ধার নিয়েছি (বাকি)", en: "Borrowed (due)" },
  recentTxns: { bn: "সাম্প্রতিক লেনদেন", en: "Recent transactions" },
  viewAll: { bn: "সব দেখুন", en: "View all" },
  navHome: { bn: "হোম", en: "Home" },
  navTxns: { bn: "লেনদেন", en: "Transactions" },
  navLoans: { bn: "ধার-দেনা", en: "Loans" },
  navReports: { bn: "রিপোর্ট", en: "Reports" },
  navPlanner: { bn: "পরিকল্পনা", en: "Planner" },
  loggedInAs: { bn: "লগইন করা আছে", en: "Logged in as" },
  demoUser: { bn: "ডেমো ইউজার", en: "Demo user" },
  searchTxn: { bn: "ক্যাটাগরি বা নোট খুঁজুন", en: "Search category or note" },
  searchLoan: { bn: "নাম দিয়ে খুঁজুন", en: "Search by name" },
  allCategory: { bn: "সব ক্যাটাগরি", en: "All categories" },
  fAll: { bn: "সব", en: "All" },
  fIncome: { bn: "আয়", en: "Income" },
  fExpense: { bn: "খরচ", en: "Expense" },
  noTxn: { bn: "কোনো লেনদেন পাওয়া যায়নি", en: "No transactions found" },
  noLoan: { bn: "কেউ পাওয়া যায়নি", en: "No one found" },
  lentTab: { bn: "আমি দিয়েছি", en: "I lent" },
  borrowedTab: { bn: "আমি নিয়েছি", en: "I borrowed" },
  paidBadge: { bn: "পরিশোধিত", en: "Paid" },
  dueBadge: { bn: "বাকি আছে", en: "Due" },
  paidSoFar: { bn: "শোধ হয়েছে", en: "Paid so far" },
  dueDateLabel: { bn: "ফেরতের তারিখ", en: "Due date" },
  totalLentBanner: { bn: "মোট ধার দিয়েছেন", en: "Total lent out" },
  totalBorrowedBanner: { bn: "মোট ধার নিয়েছেন", en: "Total borrowed" },
  stillDue: { bn: "বাকি আছে", en: "still due" },
  addPayment: { bn: "পেমেন্ট যোগ করুন", en: "Add payment" },
  recordPaymentTitle: { bn: "পেমেন্ট রেকর্ড করুন", en: "Record a payment" },
  paymentAmount: { bn: "কত টাকা?", en: "How much?" },
  paymentDate: { bn: "কোন তারিখে?", en: "On what date?" },
  recordBtn: { bn: "রেকর্ড করুন", en: "Record" },
  trendTitle: { bn: "আয় বনাম খরচ (৬ মাস)", en: "Income vs expense (6 months)" },
  catTitle: { bn: "খরচ কোথায় হচ্ছে", en: "Where the money goes" },
  addTxnTitle: { bn: "নতুন লেনদেন যোগ করুন", en: "Add new transaction" },
  addLoanTitle: { bn: "নতুন ধার-দেনা যোগ করুন", en: "Add new loan" },
  amountLabel: { bn: "পরিমাণ (৳)", en: "Amount (৳)" },
  amountPh: { bn: "যেমন ৫০০", en: "e.g. 500" },
  amountPhLoan: { bn: "যেমন ৫০০০", en: "e.g. 5000" },
  categoryLabel: { bn: "ক্যাটাগরি", en: "Category" },
  noteLabel: { bn: "নোট (ঐচ্ছিক)", en: "Note (optional)" },
  notePhTxn: { bn: "যেমন বাজার খরচ", en: "e.g. groceries" },
  dateLabel: { bn: "তারিখ", en: "Date" },
  save: { bn: "সংরক্ষণ করুন", en: "Save" },
  lentTo: { bn: "কাকে দিয়েছেন", en: "Lent to" },
  borrowedFrom: { bn: "কার থেকে নিয়েছেন", en: "Borrowed from" },
  namePh: { bn: "নাম লিখুন", en: "Enter name" },
  returnDate: { bn: "ফেরত দেওয়ার তারিখ", en: "Return date" },
  notePhLoan: { bn: "কারণ লিখুন", en: "Reason" },
  welcome: { bn: "স্বাগতম", en: "Welcome" },
  loginSub: { bn: "আপনার হিসাব দেখতে লগইন করুন", en: "Log in to see your accounts" },
  emailLabel: { bn: "ইমেইল", en: "Email" },
  passwordLabel: { bn: "পাসওয়ার্ড", en: "Password" },
  loginBtn: { bn: "লগইন করুন", en: "Log in" },
  newHere: { bn: "নতুন এখানে?", en: "New here?" },
  createAccountLink: { bn: "অ্যাকাউন্ট তৈরি করুন", en: "Create account" },
  forgotLink: { bn: "পাসওয়ার্ড ভুলে গেছেন?", en: "Forgot password?" },
  demoHint: { bn: "ডেমো: এখনো কোনো অ্যাকাউন্ট তৈরি না হলে, যেকোনো ইমেইল-পাসওয়ার্ড দিয়ে ঢোকা যাবে।", en: "Demo: if no account is created yet, any email/password will log you in." },
  signupTitle: { bn: "অ্যাকাউন্ট তৈরি করুন", en: "Create account" },
  signupSub: { bn: "ইমেইল দিন, আমরা একটি OTP পাঠাবো", en: "Enter your email, we'll send an OTP" },
  sendOtp: { bn: "OTP পাঠান", en: "Send OTP" },
  haveAccount: { bn: "আগে থেকে অ্যাকাউন্ট আছে?", en: "Already have an account?" },
  otpTitle: { bn: "OTP যাচাই করুন", en: "Verify OTP" },
  otpCode: { bn: "OTP কোড", en: "OTP code" },
  verify: { bn: "যাচাই করুন", en: "Verify" },
  noCode: { bn: "কোড পাননি?", en: "Didn't get a code?" },
  resend: { bn: "আবার পাঠান", en: "Resend" },
  otpResent: { bn: "নতুন OTP পাঠানো হয়েছে", en: "A new OTP has been sent" },
  demoOtp: { bn: "ডেমো OTP: 123456", en: "Demo OTP: 123456" },
  setPassTitle: { bn: "পাসওয়ার্ড সেট করুন", en: "Set a password" },
  setPassSub: { bn: "এই পাসওয়ার্ড দিয়ে যেকোনো ফোন থেকে লগইন করতে পারবেন", en: "You can log in from any phone with this password" },
  forgotTitle: { bn: "পাসওয়ার্ড রিসেট করুন", en: "Reset password" },
  forgotSub: { bn: "ইমেইল দিন, আমরা একটি OTP পাঠাবো", en: "Enter your email, we'll send an OTP" },
  resetPassTitle: { bn: "নতুন পাসওয়ার্ড দিন", en: "Set a new password" },
  resetSuccess: { bn: "পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে। এখন লগইন করুন।", en: "Password changed successfully. Please log in." },
  backToLogin: { bn: "লগইনে ফিরে যান", en: "Back to login" },
  newPassword: { bn: "নতুন পাসওয়ার্ড", en: "New password" },
  confirmPassword: { bn: "পাসওয়ার্ড নিশ্চিত করুন", en: "Confirm password" },
  minChars: { bn: "কমপক্ষে ৬ ক্যারেক্টার", en: "At least 6 characters" },
  reenter: { bn: "পুনরায় লিখুন", en: "Re-enter" },
  createAccountBtn: { bn: "অ্যাকাউন্ট তৈরি করুন", en: "Create account" },
  resetBtn: { bn: "পাসওয়ার্ড পরিবর্তন করুন", en: "Change password" },
  errInvalidEmail: { bn: "সঠিক ইমেইল ঠিকানা দিন", en: "Enter a valid email address" },
  errWrongOtp: { bn: "ভুল OTP, আবার চেষ্টা করুন", en: "Wrong OTP, try again" },
  errPassShort: { bn: "পাসওয়ার্ড কমপক্ষে ৬ ক্যারেক্টার হতে হবে", en: "Password must be at least 6 characters" },
  errPassMismatch: { bn: "পাসওয়ার্ড দুটো মিলছে না", en: "Passwords don't match" },
  errFillBoth: { bn: "ইমেইল ও পাসওয়ার্ড দিন", en: "Enter email and password" },
  errWrongCreds: { bn: "ইমেইল বা পাসওয়ার্ড সঠিক নয়", en: "Incorrect email or password" },
  otpSubtitlePrefix: { bn: "এ পাঠানো ৬ ডিজিটের কোড দিন", en: "Enter the 6-digit code sent to" },
  logout: { bn: "লগআউট", en: "Log out" },
  expenseWord: { bn: "খরচ", en: "Expense" },
  incomeWord: { bn: "আয়", en: "Income" },
  plannerTitle: { bn: "আগামীকালের পরিকল্পনা", en: "Tomorrow's plan" },
  plannerSub: { bn: "কালকের জন্য কী করবেন লিখে রাখুন", en: "Jot down what you'll do tomorrow" },
  forDate: { bn: "তারিখ", en: "For date" },
  planPlaceholder: { bn: "যেমন: বাজার করা, বিদ্যুৎ বিল দেওয়া, রফিক ভাইকে টাকা ফেরত দেওয়া...", en: "e.g. groceries, pay electricity bill, return money to Rafiq..." },
  savePlan: { bn: "পরিকল্পনা সংরক্ষণ করুন", en: "Save plan" },
  yourPlans: { bn: "আপনার পরিকল্পনাগুলো", en: "Your plans" },
  noPlans: { bn: "এখনো কোনো পরিকল্পনা লেখা হয়নি", en: "No plans written yet" },
  advFilterTitle: { bn: "বিস্তারিত সার্চ ফিল্টার", en: "Advanced search filters" },
  categoryLabelMulti: { bn: "ক্যাটাগরি (একাধিক বাছাই করা যাবে)", en: "Category (pick multiple)" },
  dateFrom: { bn: "শুরুর তারিখ", en: "From date" },
  dateTo: { bn: "শেষ তারিখ", en: "To date" },
  minAmount: { bn: "সর্বনিম্ন পরিমাণ (৳)", en: "Minimum amount (৳)" },
  maxAmount: { bn: "সর্বোচ্চ পরিমাণ (৳)", en: "Maximum amount (৳)" },
  applyFilters: { bn: "ফিল্টার প্রয়োগ করুন", en: "Apply filters" },
  resetFilters: { bn: "রিসেট করুন", en: "Reset" },
  statusLabel: { bn: "স্ট্যাটাস", en: "Status" },
  statusAll: { bn: "সব", en: "All" },
  statusDue: { bn: "বাকি আছে", en: "Due" },
  statusPaid: { bn: "পরিশোধিত", en: "Paid" },
  filtersActive: { bn: "টি ফিল্টার সক্রিয়", en: "filters active" },
};

const CATS = {
  food: { icon: UtensilsCrossed, color: "#FF6F61", label: { bn: "খাবার", en: "Food" } },
  rent: { icon: HomeIcon, color: "#D89A4E", label: { bn: "বাসাভাড়া", en: "Rent" } },
  transport: { icon: Bus, color: "#6FA0E8", label: { bn: "যাতায়াত", en: "Transport" } },
  bills: { icon: Zap, color: "#E8B84B", label: { bn: "বিল", en: "Bills" } },
  shopping: { icon: ShoppingBag, color: "#B27FE8", label: { bn: "কেনাকাটা", en: "Shopping" } },
  health: { icon: HeartPulse, color: "#E87FB0", label: { bn: "স্বাস্থ্য", en: "Health" } },
  education: { icon: GraduationCap, color: "#2FBF9F", label: { bn: "শিক্ষা", en: "Education" } },
  other: { icon: MoreHorizontal, color: "#8B7D93", label: { bn: "অন্যান্য", en: "Other" } },
  loanGiven: { icon: HandCoins, color: COLORS.lent, label: { bn: "ধার দেওয়া", en: "Loan given" } },
  loanRepayExpense: { icon: HandCoins, color: COLORS.expense, label: { bn: "ধার শোধ করলাম", en: "Loan repaid by me" } },
};

const INCOME_CATS = {
  salary: { icon: Briefcase, label: { bn: "বেতন", en: "Salary" } },
  business: { icon: TrendingUp, label: { bn: "ব্যবসা", en: "Business" } },
  otherIncome: { icon: Gift, label: { bn: "অন্যান্য আয়", en: "Other income" } },
  loanTaken: { icon: HandCoins, label: { bn: "ধার নেওয়া", en: "Loan taken" } },
  loanRepayIncome: { icon: HandCoins, label: { bn: "ধার ফেরত পেলাম", en: "Loan repaid to me" } },
};

const MONTHS = {
  mar: { bn: "মার্চ", en: "Mar" }, apr: { bn: "এপ্রিল", en: "Apr" }, may: { bn: "মে", en: "May" },
  jun: { bn: "জুন", en: "Jun" }, jul: { bn: "জুলাই", en: "Jul" }, aug: { bn: "আগস্ট", en: "Aug" },
};

const todayStr = () => new Date().toISOString().slice(0, 10);
const tomorrowStr = () => new Date(Date.now() + 86400000).toISOString().slice(0, 10);
const fmt = (n) => "৳" + Math.abs(n).toLocaleString("en-BD", { maximumFractionDigits: 0 });
const bi = (bnV, enV) => ({ bn: bnV, en: enV });

const initialTxns = [
  { id: 1, type: "income", category: "salary", amount: 45000, note: bi("মাসিক বেতন", "Monthly salary"), date: "2026-08-01" },
  { id: 2, type: "expense", category: "rent", amount: 12000, note: bi("আগস্ট মাসের ভাড়া", "August rent"), date: "2026-08-02" },
  { id: 3, type: "expense", category: "food", amount: 850, note: bi("বাজার খরচ", "Grocery shopping"), date: "2026-08-10" },
  { id: 4, type: "expense", category: "transport", amount: 300, note: bi("রিকশা + বাস", "Rickshaw + bus"), date: "2026-08-11" },
  { id: 5, type: "expense", category: "bills", amount: 1800, note: bi("ইলেকট্রিসিটি + ইন্টারনেট", "Electricity + internet"), date: "2026-08-12" },
  { id: 6, type: "income", category: "business", amount: 6000, note: bi("ফ্রিল্যান্স কাজ", "Freelance work"), date: "2026-08-13" },
  { id: 7, type: "expense", category: "shopping", amount: 2200, note: bi("জামা কাপড়", "Clothes"), date: "2026-08-14" },
  { id: 8, type: "expense", category: "loanGiven", amount: 5000, note: bi("রফিক ভাই", "Rafiq Bhai"), date: "2026-07-20", linkedLoanId: 1 },
  { id: 9, type: "income", category: "loanRepayIncome", amount: 2000, note: bi("রফিক ভাই", "Rafiq Bhai"), date: "2026-08-05", linkedLoanId: 1 },
  { id: 10, type: "expense", category: "loanGiven", amount: 1500, note: bi("সুমাইয়া", "Sumaiya"), date: "2026-06-10", linkedLoanId: 2 },
  { id: 11, type: "income", category: "loanRepayIncome", amount: 1500, note: bi("সুমাইয়া", "Sumaiya"), date: "2026-07-08", linkedLoanId: 2 },
  { id: 12, type: "income", category: "loanTaken", amount: 10000, note: bi("আব্বু", "Dad"), date: "2026-05-01", linkedLoanId: 3 },
  { id: 13, type: "expense", category: "loanRepayExpense", amount: 4000, note: bi("আব্বু", "Dad"), date: "2026-07-15", linkedLoanId: 3 },
  { id: 14, type: "income", category: "loanTaken", amount: 2000, note: bi("কামাল ভাই", "Kamal Bhai"), date: "2026-08-05", linkedLoanId: 4 },
];

const initialLoans = [
  { id: 1, type: "lent", person: bi("রফিক ভাই", "Rafiq Bhai"), amount: 5000, paid: 2000, date: "2026-07-20", dueDate: "2026-08-30", note: bi("ব্যক্তিগত প্রয়োজনে", "Personal need") },
  { id: 2, type: "lent", person: bi("সুমাইয়া", "Sumaiya"), amount: 1500, paid: 1500, date: "2026-06-10", dueDate: "2026-07-10", note: bi("কোর্স ফি", "Course fee") },
  { id: 3, type: "borrowed", person: bi("আব্বু", "Dad"), amount: 10000, paid: 4000, date: "2026-05-01", dueDate: "2026-09-01", note: bi("ল্যাপটপ কেনার জন্য", "For buying a laptop") },
  { id: 4, type: "borrowed", person: bi("কামাল ভাই", "Kamal Bhai"), amount: 2000, paid: 0, date: "2026-08-05", dueDate: "2026-08-25", note: bi("", "") },
];

const trendData = [
  { id: "mar", income: 42000, expense: 31000 }, { id: "apr", income: 44000, expense: 33500 },
  { id: "may", income: 43500, expense: 29800 }, { id: "jun", income: 47000, expense: 35200 },
  { id: "jul", income: 46000, expense: 32100 }, { id: "aug", income: 51000, expense: 17150 },
];

const initialPlans = [{ id: 1, date: "2026-08-16", text: bi("বাজার করা, বিদ্যুৎ বিল দেওয়া, জিমে যাওয়া", "Groceries, pay electricity bill, go to gym") }];

const glassInput = {
  fontFamily: "'Hind Siliguri', sans-serif",
  background: COLORS.glassInput,
  border: "1px solid rgba(255,255,255,0.8)",
  borderRadius: 12,
  padding: "10px 12px",
  width: "100%",
  color: COLORS.ink,
  fontSize: 14.5,
  backdropFilter: "blur(8px)",
  WebkitBackdropFilter: "blur(8px)",
  transition: "border-color 0.15s, box-shadow 0.15s",
};

function GlobalStyle() {
  return (
    <style>{`
      @import url('https://fonts.googleapis.com/css2?family=Tiro+Bangla&family=Hind+Siliguri:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap');
      * { box-sizing: border-box; }
      .num { font-family: 'Space Grotesk', sans-serif; }
      ::-webkit-scrollbar { width: 0px; }
      @keyframes fadeInUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
      @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
      @keyframes floatGlow { 0%,100% { box-shadow: 0 8px 24px rgba(232,184,75,0.45); } 50% { box-shadow: 0 10px 32px rgba(232,184,75,0.7); } }
      @keyframes bgShift { 0% { background-position: 0% 30%; } 50% { background-position: 100% 70%; } 100% { background-position: 0% 30%; } }
      .anim-fadeup { animation: fadeInUp 0.45s ease both; }
      .anim-fadein { animation: fadeIn 0.3s ease both; }
      .anim-fab { animation: floatGlow 2.6s ease-in-out infinite; }
      .press { transition: transform 0.12s ease; }
      .press:active { transform: scale(0.94); }
      .bg-anim { background-size: 300% 300%; animation: bgShift 14s ease infinite; }
      input:focus, textarea:focus { outline: none; border-color: ${COLORS.gold} !important; box-shadow: 0 0 0 3px ${COLORS.goldSoft}; }
    `}</style>
  );
}

function Glass({ children, dark, style, className = "" }) {
  return (
    <div
      className={className}
      style={{
        background: dark ? COLORS.glassDark : COLORS.glass,
        border: `1px solid ${dark ? COLORS.glassDarkBorder : COLORS.glassBorder}`,
        backdropFilter: "blur(18px)",
        WebkitBackdropFilter: "blur(18px)",
        boxShadow: dark ? "0 8px 32px rgba(0,0,0,0.25)" : "0 8px 32px rgba(80,40,110,0.12)",
        ...style,
      }}
    >
      {children}
    </div>
  );
}

function StitchRing({ children }) {
  return (
    <div style={{ border: `2px dashed ${COLORS.goldSoft}`, borderRadius: "9999px", padding: 10 }}>
      <Glass style={{ borderRadius: "9999px" }}>{children}</Glass>
    </div>
  );
}

function TabButton({ active, onClick, icon: Icon, label }) {
  return (
    <button onClick={onClick} className="flex flex-col items-center justify-center gap-1 flex-1 py-2 press" style={{ color: active ? COLORS.deepText : "#B7A6C4" }}>
      <Icon size={20} strokeWidth={active ? 2.4 : 1.8} style={{ transition: "transform 0.2s", transform: active ? "translateY(-1px)" : "none" }} />
      <span style={{ fontFamily: "'Hind Siliguri', sans-serif", fontSize: 11, fontWeight: active ? 600 : 400 }}>{label}</span>
      {active && <span style={{ width: 4, height: 4, borderRadius: 9999, background: COLORS.gold, marginTop: -2 }} className="anim-fadein" />}
    </button>
  );
}

function Sheet({ title, onClose, children }) {
  return (
    <div className="absolute inset-0 z-30 flex flex-col justify-end anim-fadein" style={{ background: "rgba(20,8,32,0.45)" }} onClick={onClose}>
      <div onClick={(e) => e.stopPropagation()} className="rounded-t-3xl p-5 max-h-[85%] overflow-y-auto anim-fadeup" style={{ background: "rgba(255,250,244,0.9)", backdropFilter: "blur(24px)", WebkitBackdropFilter: "blur(24px)", borderTop: "1px solid rgba(255,255,255,0.9)" }}>
        <div className="flex items-center justify-between mb-4">
          <h3 style={{ fontFamily: "'Tiro Bangla', serif", color: COLORS.deepText, fontSize: 19 }}>{title}</h3>
          <button onClick={onClose} style={{ color: COLORS.muted }} className="press">
            <X size={20} />
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}

function FieldLabel({ children }) {
  return <label style={{ fontFamily: "'Hind Siliguri', sans-serif", color: COLORS.muted, fontSize: 12.5 }} className="block mb-1.5 mt-3">{children}</label>;
}

function LangToggle({ lang, setLang, light }) {
  return (
    <button
      onClick={() => setLang(lang === "bn" ? "en" : "bn")}
      className="flex items-center gap-1.5 px-2.5 py-1 rounded-full press"
      style={{ border: `1px solid ${light ? "rgba(255,255,255,0.35)" : "rgba(255,255,255,0.8)"}`, background: light ? "rgba(255,255,255,0.12)" : "rgba(255,255,255,0.6)", backdropFilter: "blur(6px)" }}
    >
      <Languages size={13} color={light ? "#F2E4C6" : COLORS.deepText} />
      <span style={{ fontSize: 11.5, fontWeight: 600, color: light ? "#F2E4C6" : COLORS.deepText, fontFamily: "'Hind Siliguri', sans-serif" }}>{lang === "bn" ? "EN" : "বাং"}</span>
    </button>
  );
}

function AuthContainer({ title, subtitle, children, lang, setLang }) {
  return (
    <div className="h-full flex flex-col relative">
      <div className="absolute inset-0 bg-anim" style={{ background: "linear-gradient(120deg, #4A2470, #7A3B8F, #B25A7A, #E8935C)" }} />
      <div className="relative px-6 pt-14 pb-8 flex-shrink-0">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Wallet size={20} color={COLORS.gold} />
            <span style={{ fontFamily: "'Tiro Bangla', serif", color: "#fff", fontSize: 20 }}>{T.appName[lang]}</span>
          </div>
          <LangToggle lang={lang} setLang={setLang} light />
        </div>
        <div className="anim-fadeup" style={{ fontFamily: "'Tiro Bangla', serif", color: "#fff", fontSize: 24, marginTop: 16 }}>{title}</div>
        {subtitle && <div style={{ color: "rgba(255,255,255,0.75)", fontSize: 12.5, marginTop: 4 }}>{subtitle}</div>}
      </div>
      <Glass className="relative flex-1 px-6 pt-6 pb-8 overflow-y-auto anim-fadeup" style={{ borderRadius: "28px 28px 0 0", borderBottom: "none" }}>
        {children}
      </Glass>
    </div>
  );
}

function PrimaryButton({ children, onClick }) {
  return (
    <button onClick={onClick} className="w-full py-3 rounded-xl mt-5 font-medium press" style={{ background: `linear-gradient(135deg, ${COLORS.gold}, #F0C563)`, color: "#3B1E00", boxShadow: "0 6px 16px rgba(232,184,75,0.4)" }}>
      {children}
    </button>
  );
}

function AuthInput({ icon: Icon, ...props }) {
  return (
    <div className="relative">
      <Icon size={16} color={COLORS.muted} style={{ position: "absolute", left: 12, top: 13 }} />
      <input {...props} style={{ ...glassInput, paddingLeft: 36 }} />
    </div>
  );
}

function ErrorText({ children }) {
  if (!children) return null;
  return <div className="anim-fadein" style={{ color: "#D6335A", fontSize: 12.5, marginTop: 10, fontFamily: "'Hind Siliguri', sans-serif" }}>{children}</div>;
}
function InfoText({ children }) {
  if (!children) return null;
  return <div className="anim-fadein" style={{ color: COLORS.income, fontSize: 12.5, marginTop: 10, fontFamily: "'Hind Siliguri', sans-serif" }}>{children}</div>;
}

export default function App() {
  const [lang, setLang] = useState("bn");
  const t = (key) => T[key][lang];

  const [authStep, setAuthStep] = useState("login");
  const [account, setAccount] = useState(null);
  const [signupEmail, setSignupEmail] = useState("");
  const [otpInput, setOtpInput] = useState("");
  const [pass1, setPass1] = useState("");
  const [pass2, setPass2] = useState("");
  const [loginEmail, setLoginEmail] = useState("");
  const [loginPass, setLoginPass] = useState("");
  const [authError, setAuthError] = useState("");
  const [authInfo, setAuthInfo] = useState("");
  const [forgotEmail, setForgotEmail] = useState("");
  const [showDrawer, setShowDrawer] = useState(false);

  function sendOtp() { if (!signupEmail.includes("@")) return setAuthError(t("errInvalidEmail")); setAuthError(""); setAuthStep("otp"); }
  function verifyOtp() { if (otpInput !== "123456") return setAuthError(t("errWrongOtp")); setAuthError(""); setAuthStep("setpass"); }
  function createAccount() {
    if (pass1.length < 6) return setAuthError(t("errPassShort"));
    if (pass1 !== pass2) return setAuthError(t("errPassMismatch"));
    setAccount({ email: signupEmail, password: pass1 }); setAuthError(""); setAuthStep("app");
  }
  function handleLogin() {
    if (!loginEmail || !loginPass) return setAuthError(t("errFillBoth"));
    if (account && (loginEmail !== account.email || loginPass !== account.password)) return setAuthError(t("errWrongCreds"));
    setAuthError(""); setAuthStep("app");
  }
  function logout() { setAuthStep("login"); setLoginEmail(""); setLoginPass(""); setAuthError(""); setShowDrawer(false); }
  function sendForgotOtp() { if (!forgotEmail.includes("@")) return setAuthError(t("errInvalidEmail")); setAuthError(""); setAuthStep("forgotOtp"); }
  function verifyForgotOtp() { if (otpInput !== "123456") return setAuthError(t("errWrongOtp")); setAuthError(""); setAuthStep("forgotSetPass"); }
  function resetPassword() {
    if (pass1.length < 6) return setAuthError(t("errPassShort"));
    if (pass1 !== pass2) return setAuthError(t("errPassMismatch"));
    setAccount({ email: forgotEmail, password: pass1 });
    setLoginEmail(forgotEmail); setPass1(""); setPass2(""); setOtpInput(""); setAuthError("");
    setAuthInfo(t("resetSuccess")); setAuthStep("login");
  }

  const [tab, setTab] = useState("home");
  const [txns, setTxns] = useState(initialTxns);
  const [loans, setLoans] = useState(initialLoans);
  const [loanTab, setLoanTab] = useState("lent");
  const [txnFilter, setTxnFilter] = useState("all");
  const [txnSearch, setTxnSearch] = useState("");
  const [txnCategoryFilter, setTxnCategoryFilter] = useState("all");
  const [showTxnFilters, setShowTxnFilters] = useState(false);
  const [advCategories, setAdvCategories] = useState([]);
  const [advDateFrom, setAdvDateFrom] = useState("");
  const [advDateTo, setAdvDateTo] = useState("");
  const [advAmountMin, setAdvAmountMin] = useState("");
  const [advAmountMax, setAdvAmountMax] = useState("");
  const [showAdvFilter, setShowAdvFilter] = useState(false);
  const [loanSearch, setLoanSearch] = useState("");
  const [loanStatusFilter, setLoanStatusFilter] = useState("all");
  const [loanAdvMin, setLoanAdvMin] = useState("");
  const [loanAdvMax, setLoanAdvMax] = useState("");
  const [loanAdvDateFrom, setLoanAdvDateFrom] = useState("");
  const [loanAdvDateTo, setLoanAdvDateTo] = useState("");
  const [showLoanAdvFilter, setShowLoanAdvFilter] = useState(false);
  const [showAddTxn, setShowAddTxn] = useState(false);
  const [showAddLoan, setShowAddLoan] = useState(false);
  const [paymentTarget, setPaymentTarget] = useState(null);
  const [paymentAmount, setPaymentAmount] = useState("");
  const [paymentDate, setPaymentDate] = useState(todayStr());
  const [plans, setPlans] = useState(initialPlans);
  const [planDate, setPlanDate] = useState(tomorrowStr());
  const [planText, setPlanText] = useState("");

  const [newTxn, setNewTxn] = useState({ type: "expense", category: "food", amount: "", note: "", date: todayStr() });
  const [newLoan, setNewLoan] = useState({ type: "lent", person: "", amount: "", date: todayStr(), dueDate: "", note: "" });

  const totals = useMemo(() => {
    const income = txns.filter((x) => x.type === "income").reduce((s, x) => s + x.amount, 0);
    const expense = txns.filter((x) => x.type === "expense").reduce((s, x) => s + x.amount, 0);
    const lentOut = loans.filter((l) => l.type === "lent").reduce((s, l) => s + (l.amount - l.paid), 0);
    const owedOut = loans.filter((l) => l.type === "borrowed").reduce((s, l) => s + (l.amount - l.paid), 0);
    return { income, expense, lentOut, owedOut, pocket: income - expense };
  }, [txns, loans]);

  const loanTotals = useMemo(() => {
    const totalLent = loans.filter((l) => l.type === "lent").reduce((s, l) => s + l.amount, 0);
    const totalBorrowed = loans.filter((l) => l.type === "borrowed").reduce((s, l) => s + l.amount, 0);
    return { totalLent, totalBorrowed, dueLent: totals.lentOut, dueBorrowed: totals.owedOut };
  }, [loans, totals]);

  const catBreakdown = useMemo(() => {
    const map = {};
    txns.filter((x) => x.type === "expense").forEach((x) => { map[x.category] = (map[x.category] || 0) + x.amount; });
    return Object.entries(map).map(([id, value]) => ({ id, value, color: CATS[id]?.color || "#999", label: CATS[id]?.label[lang] || id })).sort((a, b) => b.value - a.value);
  }, [txns, lang]);

  const gaugeData = [{ name: "left", value: Math.max(totals.pocket, 0) }, { name: "spent", value: totals.expense }];
  const trendLocalized = trendData.map((d) => ({ ...d, m: MONTHS[d.id][lang] }));

  const filteredTxns = txns
    .filter((x) => (txnFilter === "all" ? true : txnFilter === "income" ? x.type === "income" : x.type === "expense"))
    .filter((x) => (txnCategoryFilter === "all" ? true : x.category === txnCategoryFilter))
    .filter((x) => (advCategories.length === 0 ? true : advCategories.includes(x.category)))
    .filter((x) => (!advDateFrom || x.date >= advDateFrom))
    .filter((x) => (!advDateTo || x.date <= advDateTo))
    .filter((x) => (!advAmountMin || x.amount >= Number(advAmountMin)))
    .filter((x) => (!advAmountMax || x.amount <= Number(advAmountMax)))
    .filter((x) => {
      const q = txnSearch.trim().toLowerCase();
      if (!q) return true;
      const catLabel = (CATS[x.category] || INCOME_CATS[x.category])?.label[lang]?.toLowerCase() || "";
      return catLabel.includes(q) || (x.note?.[lang] || "").toLowerCase().includes(q);
    })
    .sort((a, b) => (a.date < b.date ? 1 : -1));

  const advFilterCount = (advCategories.length > 0 ? 1 : 0) + (advDateFrom ? 1 : 0) + (advDateTo ? 1 : 0) + (advAmountMin ? 1 : 0) + (advAmountMax ? 1 : 0);

  const filteredLoans = loans
    .filter((l) => l.type === loanTab)
    .filter((l) => (loanStatusFilter === "all" ? true : loanStatusFilter === "due" ? l.amount - l.paid > 0 : l.amount - l.paid === 0))
    .filter((l) => (!loanAdvMin || l.amount >= Number(loanAdvMin)))
    .filter((l) => (!loanAdvMax || l.amount <= Number(loanAdvMax)))
    .filter((l) => (!loanAdvDateFrom || l.date >= loanAdvDateFrom))
    .filter((l) => (!loanAdvDateTo || l.date <= loanAdvDateTo))
    .filter((l) => {
      const q = loanSearch.trim().toLowerCase();
      if (!q) return true;
      return (l.person[lang] || "").toLowerCase().includes(q) || (l.note?.[lang] || "").toLowerCase().includes(q);
    });

  const loanAdvFilterCount = (loanStatusFilter !== "all" ? 1 : 0) + (loanAdvMin ? 1 : 0) + (loanAdvMax ? 1 : 0) + (loanAdvDateFrom ? 1 : 0) + (loanAdvDateTo ? 1 : 0);

  function resetAdvFilters() {
    setAdvCategories([]); setAdvDateFrom(""); setAdvDateTo(""); setAdvAmountMin(""); setAdvAmountMax("");
  }
  function resetLoanAdvFilters() {
    setLoanStatusFilter("all"); setLoanAdvMin(""); setLoanAdvMax(""); setLoanAdvDateFrom(""); setLoanAdvDateTo("");
  }
  function toggleAdvCategory(id) {
    setAdvCategories((prev) => (prev.includes(id) ? prev.filter((c) => c !== id) : [...prev, id]));
  }

  const sortedPlans = [...plans].sort((a, b) => (a.date < b.date ? 1 : -1));

  function addTxn() {
    if (!newTxn.amount) return;
    setTxns([{ id: Date.now(), type: newTxn.type, category: newTxn.category, amount: Number(newTxn.amount), note: { bn: newTxn.note, en: newTxn.note }, date: newTxn.date }, ...txns]);
    setNewTxn({ type: "expense", category: "food", amount: "", note: "", date: todayStr() });
    setShowAddTxn(false);
  }
  function addLoan() {
    if (!newLoan.person || !newLoan.amount) return;
    const loanId = Date.now();
    const amt = Number(newLoan.amount);
    const personObj = { bn: newLoan.person, en: newLoan.person };
    setLoans([{ id: loanId, type: newLoan.type, person: personObj, amount: amt, paid: 0, date: newLoan.date, dueDate: newLoan.dueDate, note: { bn: newLoan.note, en: newLoan.note } }, ...loans]);
    const linkedTxn = newLoan.type === "lent"
      ? { id: loanId + 1, type: "expense", category: "loanGiven", amount: amt, note: personObj, date: newLoan.date, linkedLoanId: loanId }
      : { id: loanId + 1, type: "income", category: "loanTaken", amount: amt, note: personObj, date: newLoan.date, linkedLoanId: loanId };
    setTxns([linkedTxn, ...txns]);
    setNewLoan({ type: "lent", person: "", amount: "", date: todayStr(), dueDate: "", note: "" });
    setShowAddLoan(false);
  }
  function recordPayment() {
    if (!paymentTarget || !paymentAmount) return;
    const amt = Math.min(Number(paymentAmount), paymentTarget.amount - paymentTarget.paid);
    if (amt <= 0) return;
    setLoans(loans.map((l) => (l.id === paymentTarget.id ? { ...l, paid: l.paid + amt } : l)));
    const linkedTxn = paymentTarget.type === "lent"
      ? { id: Date.now(), type: "income", category: "loanRepayIncome", amount: amt, note: paymentTarget.person, date: paymentDate, linkedLoanId: paymentTarget.id }
      : { id: Date.now(), type: "expense", category: "loanRepayExpense", amount: amt, note: paymentTarget.person, date: paymentDate, linkedLoanId: paymentTarget.id };
    setTxns([linkedTxn, ...txns]);
    setPaymentTarget(null); setPaymentAmount(""); setPaymentDate(todayStr());
  }
  function addPlan() {
    if (!planText.trim()) return;
    setPlans([{ id: Date.now(), date: planDate, text: { bn: planText, en: planText } }, ...plans]);
    setPlanText(""); setPlanDate(tomorrowStr());
  }
  function deletePlan(id) { setPlans(plans.filter((p) => p.id !== id)); }

  const navItems = [
    { key: "home", icon: HomeIcon, label: t("navHome") },
    { key: "txns", icon: ArrowLeftRight, label: t("navTxns") },
    { key: "loans", icon: HandCoins, label: t("navLoans") },
    { key: "reports", icon: PieIcon, label: t("navReports") },
    { key: "planner", icon: NotebookPen, label: t("navPlanner") },
  ];

  return (
    <div className="w-full min-h-full flex items-center justify-center p-6 bg-anim" style={{ background: "linear-gradient(120deg, #2A1240, #5A2A6B, #8F3F63, #C9683F)", fontFamily: "'Hind Siliguri', sans-serif" }}>
      <GlobalStyle />

      <div className="relative w-full max-w-[400px] rounded-[2.5rem] overflow-hidden" style={{ height: 800, boxShadow: "0 30px 70px rgba(0,0,0,0.55), 0 0 0 6px rgba(255,255,255,0.15)" }}>
        <div className="absolute top-0 left-1/2 -translate-x-1/2 z-40" style={{ width: 130, height: 22, background: "#0E0616", borderRadius: "0 0 16px 16px" }} />

        {authStep === "login" && (
          <AuthContainer title={t("welcome")} subtitle={t("loginSub")} lang={lang} setLang={setLang}>
            <FieldLabel>{t("emailLabel")}</FieldLabel>
            <AuthInput icon={Mail} type="email" placeholder="you@example.com" value={loginEmail} onChange={(e) => setLoginEmail(e.target.value)} />
            <FieldLabel>{t("passwordLabel")}</FieldLabel>
            <AuthInput icon={Lock} type="password" placeholder="••••••••" value={loginPass} onChange={(e) => setLoginPass(e.target.value)} />
            <div className="text-right mt-2">
              <button onClick={() => { setAuthError(""); setAuthInfo(""); setAuthStep("forgotEmail"); }} style={{ color: COLORS.deepText, fontSize: 12, fontWeight: 600 }}>{t("forgotLink")}</button>
            </div>
            <ErrorText>{authError}</ErrorText>
            <InfoText>{authInfo}</InfoText>
            <PrimaryButton onClick={handleLogin}>{t("loginBtn")}</PrimaryButton>
            <div className="text-center mt-4" style={{ fontSize: 13, color: COLORS.muted }}>
              {t("newHere")} <button onClick={() => { setAuthError(""); setAuthInfo(""); setAuthStep("signup"); }} style={{ color: COLORS.deepText, fontWeight: 700 }}>{t("createAccountLink")}</button>
            </div>
            {!account && <div style={{ fontSize: 11.5, color: COLORS.muted, marginTop: 14, fontStyle: "italic" }}>{t("demoHint")}</div>}
          </AuthContainer>
        )}

        {authStep === "signup" && (
          <AuthContainer title={t("signupTitle")} subtitle={t("signupSub")} lang={lang} setLang={setLang}>
            <FieldLabel>{t("emailLabel")}</FieldLabel>
            <AuthInput icon={Mail} type="email" placeholder="you@example.com" value={signupEmail} onChange={(e) => setSignupEmail(e.target.value)} />
            <ErrorText>{authError}</ErrorText>
            <PrimaryButton onClick={sendOtp}>{t("sendOtp")}</PrimaryButton>
            <div className="text-center mt-4" style={{ fontSize: 13, color: COLORS.muted }}>
              {t("haveAccount")} <button onClick={() => { setAuthError(""); setAuthStep("login"); }} style={{ color: COLORS.deepText, fontWeight: 700 }}>{t("loginBtn")}</button>
            </div>
          </AuthContainer>
        )}

        {authStep === "otp" && (
          <AuthContainer title={t("otpTitle")} subtitle={`${signupEmail} ${t("otpSubtitlePrefix")}`} lang={lang} setLang={setLang}>
            <FieldLabel>{t("otpCode")}</FieldLabel>
            <AuthInput icon={ShieldCheck} type="text" maxLength={6} placeholder="123456" value={otpInput} onChange={(e) => setOtpInput(e.target.value.replace(/\D/g, ""))} style={{ letterSpacing: 4 }} />
            <ErrorText>{authError}</ErrorText>
            <PrimaryButton onClick={verifyOtp}>{t("verify")}</PrimaryButton>
            <div className="text-center mt-4" style={{ fontSize: 13, color: COLORS.muted }}>
              {t("noCode")} <button onClick={() => setAuthError(t("otpResent"))} style={{ color: COLORS.deepText, fontWeight: 700 }}>{t("resend")}</button>
            </div>
            <div style={{ fontSize: 11.5, color: COLORS.muted, marginTop: 14, fontStyle: "italic" }}>{t("demoOtp")}</div>
          </AuthContainer>
        )}

        {authStep === "setpass" && (
          <AuthContainer title={t("setPassTitle")} subtitle={t("setPassSub")} lang={lang} setLang={setLang}>
            <FieldLabel>{t("newPassword")}</FieldLabel>
            <AuthInput icon={Lock} type="password" placeholder={t("minChars")} value={pass1} onChange={(e) => setPass1(e.target.value)} />
            <FieldLabel>{t("confirmPassword")}</FieldLabel>
            <AuthInput icon={Lock} type="password" placeholder={t("reenter")} value={pass2} onChange={(e) => setPass2(e.target.value)} />
            <ErrorText>{authError}</ErrorText>
            <PrimaryButton onClick={createAccount}>{t("createAccountBtn")}</PrimaryButton>
          </AuthContainer>
        )}

        {authStep === "forgotEmail" && (
          <AuthContainer title={t("forgotTitle")} subtitle={t("forgotSub")} lang={lang} setLang={setLang}>
            <FieldLabel>{t("emailLabel")}</FieldLabel>
            <AuthInput icon={Mail} type="email" placeholder="you@example.com" value={forgotEmail} onChange={(e) => setForgotEmail(e.target.value)} />
            <ErrorText>{authError}</ErrorText>
            <PrimaryButton onClick={sendForgotOtp}>{t("sendOtp")}</PrimaryButton>
            <div className="text-center mt-4" style={{ fontSize: 13, color: COLORS.muted }}>
              <button onClick={() => { setAuthError(""); setAuthStep("login"); }} style={{ color: COLORS.deepText, fontWeight: 700 }}>{t("backToLogin")}</button>
            </div>
          </AuthContainer>
        )}

        {authStep === "forgotOtp" && (
          <AuthContainer title={t("otpTitle")} subtitle={`${forgotEmail} ${t("otpSubtitlePrefix")}`} lang={lang} setLang={setLang}>
            <FieldLabel>{t("otpCode")}</FieldLabel>
            <AuthInput icon={ShieldCheck} type="text" maxLength={6} placeholder="123456" value={otpInput} onChange={(e) => setOtpInput(e.target.value.replace(/\D/g, ""))} style={{ letterSpacing: 4 }} />
            <ErrorText>{authError}</ErrorText>
            <PrimaryButton onClick={verifyForgotOtp}>{t("verify")}</PrimaryButton>
            <div style={{ fontSize: 11.5, color: COLORS.muted, marginTop: 14, fontStyle: "italic" }}>{t("demoOtp")}</div>
          </AuthContainer>
        )}

        {authStep === "forgotSetPass" && (
          <AuthContainer title={t("resetPassTitle")} subtitle={t("setPassSub")} lang={lang} setLang={setLang}>
            <FieldLabel>{t("newPassword")}</FieldLabel>
            <AuthInput icon={KeyRound} type="password" placeholder={t("minChars")} value={pass1} onChange={(e) => setPass1(e.target.value)} />
            <FieldLabel>{t("confirmPassword")}</FieldLabel>
            <AuthInput icon={KeyRound} type="password" placeholder={t("reenter")} value={pass2} onChange={(e) => setPass2(e.target.value)} />
            <ErrorText>{authError}</ErrorText>
            <PrimaryButton onClick={resetPassword}>{t("resetBtn")}</PrimaryButton>
          </AuthContainer>
        )}

        {authStep === "app" && (
          <>
            <div className="absolute inset-0" style={{ background: "linear-gradient(160deg, #3A1B58 0%, #6B2E63 45%, #C9683F 100%)" }} />

            <div className="absolute inset-0 z-40" style={{ background: "rgba(10,4,18,0.55)", opacity: showDrawer ? 1 : 0, pointerEvents: showDrawer ? "auto" : "none", transition: "opacity 0.3s ease" }} onClick={() => setShowDrawer(false)} />
            <div className="absolute top-0 left-0 bottom-0 z-50 flex flex-col" style={{ width: 250, background: "rgba(20,9,32,0.65)", backdropFilter: "blur(22px)", WebkitBackdropFilter: "blur(22px)", borderRight: "1px solid rgba(255,255,255,0.12)", transform: showDrawer ? "translateX(0)" : "translateX(-100%)", transition: "transform 0.32s cubic-bezier(.2,.8,.2,1)" }}>
              <div className="px-5 pt-14 pb-5" style={{ borderBottom: "1px solid rgba(255,255,255,0.12)" }}>
                <div className="flex items-center gap-2">
                  <Sparkles size={18} color={COLORS.gold} />
                  <span style={{ fontFamily: "'Tiro Bangla', serif", color: "#fff", fontSize: 19 }}>{t("appName")}</span>
                </div>
                <div className="mt-3" style={{ fontSize: 11, color: "#D6C3E8" }}>{t("loggedInAs")}</div>
                <div style={{ fontSize: 12.5, color: COLORS.gold, fontWeight: 600 }}>{account?.email || t("demoUser")}</div>
              </div>
              <div className="flex-1 px-3 py-4 flex flex-col gap-1">
                {navItems.map((item) => (
                  <button key={item.key} onClick={() => { setTab(item.key); setShowDrawer(false); }} className="flex items-center gap-3 px-3 py-2.5 rounded-xl press" style={{ background: tab === item.key ? "rgba(232,184,75,0.18)" : "transparent", color: tab === item.key ? COLORS.gold : "#EDE3F5" }}>
                    <item.icon size={17} />
                    <span style={{ fontSize: 14 }}>{item.label}</span>
                  </button>
                ))}
              </div>
              <div className="px-3 pb-8 pt-2" style={{ borderTop: "1px solid rgba(255,255,255,0.12)" }}>
                <button onClick={logout} className="flex items-center gap-3 px-3 py-2.5 rounded-xl press w-full" style={{ color: "#FF9B8E" }}>
                  <LogOut size={17} /><span style={{ fontSize: 14 }}>{t("logout")}</span>
                </button>
              </div>
            </div>

            <div className="relative px-5 pt-8 pb-5">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <button onClick={() => setShowDrawer(true)} className="press" style={{ color: "#fff" }}><Menu size={20} /></button>
                  <span style={{ fontFamily: "'Tiro Bangla', serif", color: "#fff", fontSize: 18, letterSpacing: 0.3 }}>{t("appName")}</span>
                </div>
                <LangToggle lang={lang} setLang={setLang} light />
              </div>

              {tab === "home" && (
                <div className="flex flex-col items-center mt-5 anim-fadeup">
                  <StitchRing>
                    <div style={{ width: 176, height: 176 }}>
                      <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                          <Pie data={gaugeData} dataKey="value" innerRadius={62} outerRadius={82} startAngle={90} endAngle={-270} stroke="none" isAnimationActive animationDuration={700}>
                            <Cell fill={COLORS.gold} />
                            <Cell fill="rgba(255,255,255,0.35)" />
                          </Pie>
                        </PieChart>
                      </ResponsiveContainer>
                    </div>
                  </StitchRing>
                  <div className="text-center -mt-[118px] mb-[58px]">
                    <div style={{ color: "#fff", opacity: 0.85, fontSize: 11.5 }}>{t("inPocket")}</div>
                    <div className="num" style={{ color: "#fff", fontSize: 26, fontWeight: 700 }}>{fmt(totals.pocket)}</div>
                  </div>
                </div>
              )}

              {tab !== "home" && (
                <div className="mt-4 anim-fadeup">
                  <h2 style={{ fontFamily: "'Tiro Bangla', serif", color: "#fff", fontSize: 22 }}>
                    {tab === "txns" && t("navTxns")}{tab === "loans" && t("navLoans")}{tab === "reports" && t("navReports")}{tab === "planner" && t("navPlanner")}
                  </h2>
                </div>
              )}
            </div>

            <div key={tab} className="relative overflow-y-auto anim-fadein" style={{ height: tab === "home" ? 800 - 300 - 74 : 800 - 118 - 74 }}>
              {tab === "home" && (
                <div className="px-5 pt-3 pb-4">
                  <div className="grid grid-cols-2 gap-3">
                    <StatCard label={t("statIncome")} value={totals.income} color={COLORS.income} Icon={ArrowUpRight} delay={0} />
                    <StatCard label={t("statExpense")} value={totals.expense} color={COLORS.expense} Icon={ArrowDownRight} delay={0.05} />
                    <StatCard label={t("statLent")} value={totals.lentOut} color={COLORS.lent} Icon={HandCoins} delay={0.1} />
                    <StatCard label={t("statBorrowed")} value={totals.owedOut} color={COLORS.borrow} Icon={HandCoins} delay={0.15} />
                  </div>
                  <div className="flex items-center justify-between mt-5 mb-2">
                    <span style={{ color: "#fff", fontWeight: 600, fontSize: 14.5 }}>{t("recentTxns")}</span>
                    <button onClick={() => setTab("txns")} style={{ color: COLORS.gold, fontSize: 12.5, fontWeight: 600 }}>{t("viewAll")}</button>
                  </div>
                  <div className="flex flex-col gap-2">
                    {txns.slice(0, 4).map((x, i) => <TxnRow key={x.id} t={x} lang={lang} delay={i * 0.05} />)}
                  </div>
                </div>
              )}

              {tab === "txns" && (
                <div className="px-5 pt-3 pb-4">
                  <div className="flex gap-2 mb-2.5">
                    <div className="relative flex-1">
                      <Search size={15} color={COLORS.muted} style={{ position: "absolute", left: 11, top: 11 }} />
                      <input style={{ ...glassInput, paddingLeft: 32 }} placeholder={t("searchTxn")} value={txnSearch} onChange={(e) => setTxnSearch(e.target.value)} />
                    </div>
                    <button onClick={() => setShowAdvFilter(true)} className="relative flex items-center justify-center rounded-xl px-3 press" style={{ background: advFilterCount > 0 ? COLORS.deepText : COLORS.glass, border: "1px solid rgba(255,255,255,0.7)" }}>
                      <SlidersHorizontal size={16} color={advFilterCount > 0 ? "#fff" : COLORS.muted} />
                      {advFilterCount > 0 && (
                        <span className="absolute -top-1.5 -right-1.5 flex items-center justify-center rounded-full num" style={{ width: 16, height: 16, fontSize: 9.5, background: COLORS.gold, color: "#3B1E00", fontWeight: 700 }}>{advFilterCount}</span>
                      )}
                    </button>
                  </div>

                  <div className="flex gap-2 mb-3">
                    {[["all", t("fAll")], ["income", t("fIncome")], ["expense", t("fExpense")]].map(([val, label]) => (
                      <button key={val} onClick={() => setTxnFilter(val)} className="px-3.5 py-1.5 rounded-full text-sm press" style={{ background: txnFilter === val ? COLORS.deepText : "rgba(255,255,255,0.65)", color: txnFilter === val ? "#fff" : COLORS.muted, border: `1px solid ${txnFilter === val ? COLORS.deepText : "rgba(255,255,255,0.7)"}` }}>{label}</button>
                    ))}
                  </div>
                  <div className="flex flex-col gap-2">
                    {filteredTxns.length === 0 && <div style={{ color: "#fff", opacity: 0.8, fontSize: 13, textAlign: "center", padding: "20px 0" }}>{t("noTxn")}</div>}
                    {filteredTxns.map((x, i) => <TxnRow key={x.id} t={x} lang={lang} showDate delay={i * 0.04} />)}
                  </div>
                </div>
              )}

              {tab === "loans" && (
                <div className="px-5 pt-3 pb-4">
                  <div className="flex gap-2 mb-3">
                    <div className="relative flex-1">
                      <Search size={15} color={COLORS.muted} style={{ position: "absolute", left: 11, top: 11 }} />
                      <input style={{ ...glassInput, paddingLeft: 32 }} placeholder={t("searchLoan")} value={loanSearch} onChange={(e) => setLoanSearch(e.target.value)} />
                    </div>
                    <button onClick={() => setShowLoanAdvFilter(true)} className="relative flex items-center justify-center rounded-xl px-3 press" style={{ background: loanAdvFilterCount > 0 ? COLORS.deepText : COLORS.glass, border: "1px solid rgba(255,255,255,0.7)" }}>
                      <SlidersHorizontal size={16} color={loanAdvFilterCount > 0 ? "#fff" : COLORS.muted} />
                      {loanAdvFilterCount > 0 && (
                        <span className="absolute -top-1.5 -right-1.5 flex items-center justify-center rounded-full num" style={{ width: 16, height: 16, fontSize: 9.5, background: COLORS.gold, color: "#3B1E00", fontWeight: 700 }}>{loanAdvFilterCount}</span>
                      )}
                    </button>
                  </div>
                  <div className="flex gap-2 mb-3">
                    <button onClick={() => setLoanTab("lent")} className="flex-1 py-2 rounded-xl text-sm font-medium press" style={{ background: loanTab === "lent" ? COLORS.deepText : "rgba(255,255,255,0.65)", color: loanTab === "lent" ? "#fff" : COLORS.muted, border: `1px solid ${loanTab === "lent" ? COLORS.deepText : "rgba(255,255,255,0.7)"}` }}>{t("lentTab")}</button>
                    <button onClick={() => setLoanTab("borrowed")} className="flex-1 py-2 rounded-xl text-sm font-medium press" style={{ background: loanTab === "borrowed" ? COLORS.deepText : "rgba(255,255,255,0.65)", color: loanTab === "borrowed" ? "#fff" : COLORS.muted, border: `1px solid ${loanTab === "borrowed" ? COLORS.deepText : "rgba(255,255,255,0.7)"}` }}>{t("borrowedTab")}</button>
                  </div>

                  <Glass className="rounded-2xl p-4 mb-3 anim-fadeup" style={{ borderRadius: 20 }}>
                    <div className="flex items-center gap-2 mb-1">
                      <CircleDollarSign size={15} color={loanTab === "lent" ? COLORS.lent : COLORS.borrow} />
                      <span style={{ fontSize: 12, color: COLORS.muted }}>{loanTab === "lent" ? t("totalLentBanner") : t("totalBorrowedBanner")}</span>
                    </div>
                    <div className="num" style={{ fontSize: 24, fontWeight: 700, color: COLORS.ink }}>{fmt(loanTab === "lent" ? loanTotals.totalLent : loanTotals.totalBorrowed)}</div>
                    <div style={{ fontSize: 11.5, color: COLORS.muted, marginTop: 2 }}>
                      {fmt(loanTab === "lent" ? loanTotals.dueLent : loanTotals.dueBorrowed)} {t("stillDue")}
                    </div>
                  </Glass>

                  <div className="flex flex-col gap-2.5">
                    {filteredLoans.length === 0 && <div style={{ color: "#fff", opacity: 0.8, fontSize: 13, textAlign: "center", padding: "20px 0" }}>{t("noLoan")}</div>}
                    {filteredLoans.map((l, i) => {
                      const pct = Math.round((l.paid / l.amount) * 100);
                      const due = l.amount - l.paid;
                      return (
                        <Glass key={l.id} className="rounded-2xl p-3.5 anim-fadeup" style={{ borderRadius: 18, animationDelay: `${i * 0.05}s` }}>
                          <div className="flex items-center justify-between">
                            <span style={{ color: COLORS.deepText, fontWeight: 600, fontSize: 14.5 }}>{l.person[lang]}</span>
                            <span className="text-[11px] px-2 py-0.5 rounded-full" style={{ background: due === 0 ? "rgba(47,191,159,0.18)" : "rgba(255,111,97,0.18)", color: due === 0 ? COLORS.income : COLORS.expense }}>{due === 0 ? t("paidBadge") : t("dueBadge")}</span>
                          </div>
                          <div className="flex items-baseline gap-1.5 mt-1">
                            <span className="num" style={{ color: COLORS.ink, fontSize: 17, fontWeight: 600 }}>{fmt(l.amount)}</span>
                            {l.note?.[lang] && <span style={{ color: COLORS.muted, fontSize: 12 }}>· {l.note[lang]}</span>}
                          </div>
                          <div className="mt-2 h-1.5 rounded-full overflow-hidden" style={{ background: "rgba(255,255,255,0.5)" }}>
                            <div className="h-full rounded-full" style={{ width: `${pct}%`, background: loanTab === "lent" ? COLORS.lent : COLORS.borrow, transition: "width 0.6s ease" }} />
                          </div>
                          <div className="flex items-center justify-between mt-1.5">
                            <span style={{ color: COLORS.muted, fontSize: 11.5 }}>{t("paidSoFar")} {fmt(l.paid)}</span>
                            <span style={{ color: COLORS.muted, fontSize: 11.5 }}>{t("dueDateLabel")} {l.dueDate}</span>
                          </div>
                          {due > 0 && (
                            <button onClick={() => { setPaymentTarget(l); setPaymentAmount(""); setPaymentDate(todayStr()); }} className="w-full mt-2.5 py-1.5 rounded-lg text-xs font-medium press" style={{ background: "rgba(59,30,82,0.08)", color: COLORS.deepText, border: "1px solid rgba(59,30,82,0.15)" }}>
                              + {t("addPayment")}
                            </button>
                          )}
                        </Glass>
                      );
                    })}
                  </div>
                </div>
              )}

              {tab === "reports" && (
                <div className="px-5 pt-3 pb-4">
                  <Glass className="rounded-2xl p-4 mb-4 anim-fadeup" style={{ borderRadius: 20 }}>
                    <div style={{ color: COLORS.deepText, fontWeight: 600, fontSize: 14, marginBottom: 8 }}>{t("trendTitle")}</div>
                    <div style={{ width: "100%", height: 140 }}>
                      <ResponsiveContainer>
                        <BarChart data={trendLocalized}>
                          <XAxis dataKey="m" tick={{ fontSize: 10, fill: COLORS.muted }} axisLine={false} tickLine={false} />
                          <Tooltip contentStyle={{ fontSize: 12, borderRadius: 8, border: "1px solid rgba(255,255,255,0.7)" }} formatter={(v) => fmt(v)} />
                          <Bar dataKey="income" name={t("incomeWord")} fill={COLORS.income} radius={[3, 3, 0, 0]} barSize={9} isAnimationActive animationDuration={700} />
                          <Bar dataKey="expense" name={t("expenseWord")} fill={COLORS.expense} radius={[3, 3, 0, 0]} barSize={9} isAnimationActive animationDuration={700} />
                        </BarChart>
                      </ResponsiveContainer>
                    </div>
                  </Glass>

                  <Glass className="rounded-2xl p-4 anim-fadeup" style={{ borderRadius: 20, animationDelay: "0.1s" }}>
                    <div style={{ color: COLORS.deepText, fontWeight: 600, fontSize: 14, marginBottom: 8 }}>{t("catTitle")}</div>
                    <div className="flex items-center gap-4">
                      <div style={{ width: 110, height: 110, flexShrink: 0 }}>
                        <ResponsiveContainer>
                          <PieChart><Pie data={catBreakdown} dataKey="value" innerRadius={30} outerRadius={52} stroke="none" isAnimationActive animationDuration={700}>{catBreakdown.map((c, i) => <Cell key={i} fill={c.color} />)}</Pie></PieChart>
                        </ResponsiveContainer>
                      </div>
                      <div className="flex flex-col gap-1.5 flex-1">
                        {catBreakdown.map((c) => (
                          <div key={c.id} className="flex items-center justify-between">
                            <div className="flex items-center gap-1.5"><span style={{ width: 8, height: 8, borderRadius: 9999, background: c.color }} /><span style={{ fontSize: 12, color: COLORS.ink }}>{c.label}</span></div>
                            <span className="num" style={{ fontSize: 12, color: COLORS.muted }}>{fmt(c.value)}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </Glass>
                </div>
              )}

              {tab === "planner" && (
                <div className="px-5 pt-3 pb-4">
                  <Glass className="rounded-2xl p-4 mb-4 anim-fadeup" style={{ borderRadius: 20 }}>
                    <div className="flex items-center gap-2 mb-1"><NotebookPen size={16} color={COLORS.deepText} /><span style={{ fontFamily: "'Tiro Bangla', serif", color: COLORS.deepText, fontSize: 16 }}>{t("plannerTitle")}</span></div>
                    <div style={{ color: COLORS.muted, fontSize: 12, marginBottom: 8 }}>{t("plannerSub")}</div>
                    <FieldLabel>{t("forDate")}</FieldLabel>
                    <input style={glassInput} type="date" value={planDate} onChange={(e) => setPlanDate(e.target.value)} />
                    <FieldLabel>{t("plannerTitle")}</FieldLabel>
                    <textarea style={{ ...glassInput, minHeight: 90, resize: "none", fontFamily: "'Hind Siliguri', sans-serif" }} placeholder={t("planPlaceholder")} value={planText} onChange={(e) => setPlanText(e.target.value)} />
                    <button onClick={addPlan} className="w-full py-3 rounded-xl mt-4 font-medium press" style={{ background: `linear-gradient(135deg, ${COLORS.gold}, #F0C563)`, color: "#3B1E00", boxShadow: "0 6px 16px rgba(232,184,75,0.4)" }}>{t("savePlan")}</button>
                  </Glass>

                  <div style={{ color: "#fff", fontWeight: 600, fontSize: 14.5, marginBottom: 8 }}>{t("yourPlans")}</div>
                  <div className="flex flex-col gap-2">
                    {sortedPlans.length === 0 && <div style={{ color: "#fff", opacity: 0.8, fontSize: 13, textAlign: "center", padding: "20px 0" }}>{t("noPlans")}</div>}
                    {sortedPlans.map((p, i) => (
                      <Glass key={p.id} className="rounded-xl p-3 anim-fadeup" style={{ borderRadius: 14, animationDelay: `${i * 0.05}s` }}>
                        <div className="flex items-center justify-between mb-1">
                          <span className="num" style={{ fontSize: 11.5, color: COLORS.gold, fontWeight: 700 }}>{p.date}</span>
                          <button onClick={() => deletePlan(p.id)} className="press" style={{ color: COLORS.muted }}><Trash2 size={14} /></button>
                        </div>
                        <div style={{ fontSize: 13.5, color: COLORS.ink, lineHeight: 1.5 }}>{p.text[lang]}</div>
                      </Glass>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {(tab === "home" || tab === "txns" || tab === "loans") && (
              <button onClick={() => (tab === "loans" ? setShowAddLoan(true) : setShowAddTxn(true))} className="absolute z-20 flex items-center justify-center press anim-fab" style={{ right: 18, bottom: 86, width: 50, height: 50, borderRadius: 9999, background: `linear-gradient(135deg, ${COLORS.gold}, #F0C563)` }}>
                <Plus color="#3B1E00" size={24} strokeWidth={2.6} />
              </button>
            )}

            <div className="absolute bottom-0 left-0 right-0 flex items-stretch z-10" style={{ height: 74, background: "rgba(255,255,255,0.75)", backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)", borderTop: "1px solid rgba(255,255,255,0.8)" }}>
              <TabButton active={tab === "home"} onClick={() => setTab("home")} icon={HomeIcon} label={t("navHome")} />
              <TabButton active={tab === "txns"} onClick={() => setTab("txns")} icon={ArrowLeftRight} label={t("navTxns")} />
              <TabButton active={tab === "loans"} onClick={() => setTab("loans")} icon={HandCoins} label={t("navLoans")} />
              <TabButton active={tab === "reports"} onClick={() => setTab("reports")} icon={PieIcon} label={t("navReports")} />
            </div>

            {showAddTxn && (
              <Sheet title={t("addTxnTitle")} onClose={() => setShowAddTxn(false)}>
                <div className="flex gap-2">
                  <button onClick={() => setNewTxn({ ...newTxn, type: "expense", category: "food" })} className="flex-1 py-2 rounded-xl text-sm press" style={{ background: newTxn.type === "expense" ? COLORS.expense : "#FFFFFF", color: newTxn.type === "expense" ? "#fff" : COLORS.muted, border: "1px solid rgba(0,0,0,0.08)" }}>{t("fExpense")}</button>
                  <button onClick={() => setNewTxn({ ...newTxn, type: "income", category: "salary" })} className="flex-1 py-2 rounded-xl text-sm press" style={{ background: newTxn.type === "income" ? COLORS.income : "#FFFFFF", color: newTxn.type === "income" ? "#fff" : COLORS.muted, border: "1px solid rgba(0,0,0,0.08)" }}>{t("fIncome")}</button>
                </div>
                <FieldLabel>{t("amountLabel")}</FieldLabel>
                <input style={glassInput} type="number" placeholder={t("amountPh")} value={newTxn.amount} onChange={(e) => setNewTxn({ ...newTxn, amount: e.target.value })} />
                <FieldLabel>{t("categoryLabel")}</FieldLabel>
                <div className="flex flex-wrap gap-2">
                  {Object.entries(newTxn.type === "expense" ? { food: CATS.food, rent: CATS.rent, transport: CATS.transport, bills: CATS.bills, shopping: CATS.shopping, health: CATS.health, education: CATS.education, other: CATS.other } : { salary: INCOME_CATS.salary, business: INCOME_CATS.business, otherIncome: INCOME_CATS.otherIncome }).map(([id, meta]) => (
                    <button key={id} onClick={() => setNewTxn({ ...newTxn, category: id })} className="px-3 py-1.5 rounded-full text-xs press" style={{ background: newTxn.category === id ? COLORS.deepText : "#FFFFFF", color: newTxn.category === id ? "#fff" : COLORS.ink, border: "1px solid rgba(0,0,0,0.08)" }}>{meta.label[lang]}</button>
                  ))}
                </div>
                <FieldLabel>{t("noteLabel")}</FieldLabel>
                <input style={glassInput} placeholder={t("notePhTxn")} value={newTxn.note} onChange={(e) => setNewTxn({ ...newTxn, note: e.target.value })} />
                <FieldLabel>{t("dateLabel")}</FieldLabel>
                <input style={glassInput} type="date" value={newTxn.date} onChange={(e) => setNewTxn({ ...newTxn, date: e.target.value })} />
                <button onClick={addTxn} className="w-full py-3 rounded-xl mt-5 font-medium press" style={{ background: `linear-gradient(135deg, ${COLORS.gold}, #F0C563)`, color: "#3B1E00" }}>{t("save")}</button>
              </Sheet>
            )}

            {showAddLoan && (
              <Sheet title={t("addLoanTitle")} onClose={() => setShowAddLoan(false)}>
                <div className="flex gap-2">
                  <button onClick={() => setNewLoan({ ...newLoan, type: "lent" })} className="flex-1 py-2 rounded-xl text-sm press" style={{ background: newLoan.type === "lent" ? COLORS.deepText : "#FFFFFF", color: newLoan.type === "lent" ? "#fff" : COLORS.muted, border: "1px solid rgba(0,0,0,0.08)" }}>{t("lentTab")}</button>
                  <button onClick={() => setNewLoan({ ...newLoan, type: "borrowed" })} className="flex-1 py-2 rounded-xl text-sm press" style={{ background: newLoan.type === "borrowed" ? COLORS.deepText : "#FFFFFF", color: newLoan.type === "borrowed" ? "#fff" : COLORS.muted, border: "1px solid rgba(0,0,0,0.08)" }}>{t("borrowedTab")}</button>
                </div>
                <FieldLabel>{newLoan.type === "lent" ? t("lentTo") : t("borrowedFrom")}</FieldLabel>
                <input style={glassInput} placeholder={t("namePh")} value={newLoan.person} onChange={(e) => setNewLoan({ ...newLoan, person: e.target.value })} />
                <FieldLabel>{t("amountLabel")}</FieldLabel>
                <input style={glassInput} type="number" placeholder={t("amountPhLoan")} value={newLoan.amount} onChange={(e) => setNewLoan({ ...newLoan, amount: e.target.value })} />
                <FieldLabel>{t("dateLabel")}</FieldLabel>
                <input style={glassInput} type="date" value={newLoan.date} onChange={(e) => setNewLoan({ ...newLoan, date: e.target.value })} />
                <FieldLabel>{t("returnDate")}</FieldLabel>
                <input style={glassInput} type="date" value={newLoan.dueDate} onChange={(e) => setNewLoan({ ...newLoan, dueDate: e.target.value })} />
                <FieldLabel>{t("noteLabel")}</FieldLabel>
                <input style={glassInput} placeholder={t("notePhLoan")} value={newLoan.note} onChange={(e) => setNewLoan({ ...newLoan, note: e.target.value })} />
                <div style={{ fontSize: 11.5, color: COLORS.muted, marginTop: 10, fontStyle: "italic" }}>
                  {newLoan.type === "lent"
                    ? (lang === "bn" ? "এই টাকা আপনার খরচ হিসেবে যোগ হবে।" : "This amount will be added as your expense.")
                    : (lang === "bn" ? "এই টাকা আপনার আয় হিসেবে যোগ হবে।" : "This amount will be added as your income.")}
                </div>
                <button onClick={addLoan} className="w-full py-3 rounded-xl mt-5 font-medium press" style={{ background: `linear-gradient(135deg, ${COLORS.gold}, #F0C563)`, color: "#3B1E00" }}>{t("save")}</button>
              </Sheet>
            )}

            {showAdvFilter && (
              <Sheet title={t("advFilterTitle")} onClose={() => setShowAdvFilter(false)}>
                <FieldLabel>{t("categoryLabelMulti")}</FieldLabel>
                <div className="flex flex-wrap gap-2">
                  {[...Object.keys(CATS), ...Object.keys(INCOME_CATS)].map((id) => {
                    const label = (CATS[id] || INCOME_CATS[id]).label[lang];
                    const active = advCategories.includes(id);
                    return (
                      <button key={id} onClick={() => toggleAdvCategory(id)} className="px-3 py-1.5 rounded-full text-xs press" style={{ background: active ? COLORS.deepText : "#FFFFFF", color: active ? "#fff" : COLORS.ink, border: "1px solid rgba(0,0,0,0.08)" }}>
                        {label}
                      </button>
                    );
                  })}
                </div>

                <div className="flex gap-3">
                  <div className="flex-1">
                    <FieldLabel>{t("dateFrom")}</FieldLabel>
                    <input style={glassInput} type="date" value={advDateFrom} onChange={(e) => setAdvDateFrom(e.target.value)} />
                  </div>
                  <div className="flex-1">
                    <FieldLabel>{t("dateTo")}</FieldLabel>
                    <input style={glassInput} type="date" value={advDateTo} onChange={(e) => setAdvDateTo(e.target.value)} />
                  </div>
                </div>

                <div className="flex gap-3">
                  <div className="flex-1">
                    <FieldLabel>{t("minAmount")}</FieldLabel>
                    <input style={glassInput} type="number" placeholder="0" value={advAmountMin} onChange={(e) => setAdvAmountMin(e.target.value)} />
                  </div>
                  <div className="flex-1">
                    <FieldLabel>{t("maxAmount")}</FieldLabel>
                    <input style={glassInput} type="number" placeholder="৳৯৯৯৯৯" value={advAmountMax} onChange={(e) => setAdvAmountMax(e.target.value)} />
                  </div>
                </div>

                <div className="flex gap-2 mt-5">
                  <button onClick={resetAdvFilters} className="flex-1 py-3 rounded-xl font-medium press" style={{ background: "#FFFFFF", color: COLORS.muted, border: "1px solid rgba(0,0,0,0.08)" }}>{t("resetFilters")}</button>
                  <button onClick={() => setShowAdvFilter(false)} className="flex-1 py-3 rounded-xl font-medium press" style={{ background: `linear-gradient(135deg, ${COLORS.gold}, #F0C563)`, color: "#3B1E00" }}>{t("applyFilters")}</button>
                </div>
              </Sheet>
            )}

            {showLoanAdvFilter && (
              <Sheet title={t("advFilterTitle")} onClose={() => setShowLoanAdvFilter(false)}>
                <FieldLabel>{t("statusLabel")}</FieldLabel>
                <div className="flex gap-2">
                  {[["all", t("statusAll")], ["due", t("statusDue")], ["paid", t("statusPaid")]].map(([val, label]) => (
                    <button key={val} onClick={() => setLoanStatusFilter(val)} className="flex-1 py-2 rounded-xl text-sm press" style={{ background: loanStatusFilter === val ? COLORS.deepText : "#FFFFFF", color: loanStatusFilter === val ? "#fff" : COLORS.muted, border: "1px solid rgba(0,0,0,0.08)" }}>
                      {label}
                    </button>
                  ))}
                </div>

                <div className="flex gap-3">
                  <div className="flex-1">
                    <FieldLabel>{t("dateFrom")}</FieldLabel>
                    <input style={glassInput} type="date" value={loanAdvDateFrom} onChange={(e) => setLoanAdvDateFrom(e.target.value)} />
                  </div>
                  <div className="flex-1">
                    <FieldLabel>{t("dateTo")}</FieldLabel>
                    <input style={glassInput} type="date" value={loanAdvDateTo} onChange={(e) => setLoanAdvDateTo(e.target.value)} />
                  </div>
                </div>

                <div className="flex gap-3">
                  <div className="flex-1">
                    <FieldLabel>{t("minAmount")}</FieldLabel>
                    <input style={glassInput} type="number" placeholder="0" value={loanAdvMin} onChange={(e) => setLoanAdvMin(e.target.value)} />
                  </div>
                  <div className="flex-1">
                    <FieldLabel>{t("maxAmount")}</FieldLabel>
                    <input style={glassInput} type="number" placeholder="৳৯৯৯৯৯" value={loanAdvMax} onChange={(e) => setLoanAdvMax(e.target.value)} />
                  </div>
                </div>

                <div className="flex gap-2 mt-5">
                  <button onClick={resetLoanAdvFilters} className="flex-1 py-3 rounded-xl font-medium press" style={{ background: "#FFFFFF", color: COLORS.muted, border: "1px solid rgba(0,0,0,0.08)" }}>{t("resetFilters")}</button>
                  <button onClick={() => setShowLoanAdvFilter(false)} className="flex-1 py-3 rounded-xl font-medium press" style={{ background: `linear-gradient(135deg, ${COLORS.gold}, #F0C563)`, color: "#3B1E00" }}>{t("applyFilters")}</button>
                </div>
              </Sheet>
            )}

            {paymentTarget && (
              <Sheet title={t("recordPaymentTitle")} onClose={() => setPaymentTarget(null)}>
                <div style={{ fontSize: 14, color: COLORS.deepText, fontWeight: 600 }}>{paymentTarget.person[lang]}</div>
                <div style={{ fontSize: 12, color: COLORS.muted, marginTop: 2 }}>
                  {t("dueBadge")}: {fmt(paymentTarget.amount - paymentTarget.paid)}
                </div>
                <FieldLabel>{t("paymentAmount")}</FieldLabel>
                <input style={glassInput} type="number" placeholder={t("amountPh")} value={paymentAmount} onChange={(e) => setPaymentAmount(e.target.value)} />
                <FieldLabel>{t("paymentDate")}</FieldLabel>
                <input style={glassInput} type="date" value={paymentDate} onChange={(e) => setPaymentDate(e.target.value)} />
                <div style={{ fontSize: 11.5, color: COLORS.muted, marginTop: 10, fontStyle: "italic" }}>
                  {paymentTarget.type === "lent"
                    ? (lang === "bn" ? "এই টাকা আপনার আয় হিসেবে যোগ হবে।" : "This amount will be added as your income.")
                    : (lang === "bn" ? "এই টাকা আপনার খরচ হিসেবে যোগ হবে।" : "This amount will be added as your expense.")}
                </div>
                <button onClick={recordPayment} className="w-full py-3 rounded-xl mt-5 font-medium press" style={{ background: `linear-gradient(135deg, ${COLORS.gold}, #F0C563)`, color: "#3B1E00" }}>{t("recordBtn")}</button>
              </Sheet>
            )}
          </>
        )}
      </div>
    </div>
  );
}

function StatCard({ label, value, color, Icon, delay = 0 }) {
  return (
    <Glass className="rounded-2xl p-3 anim-fadeup" style={{ borderRadius: 16, animationDelay: `${delay}s` }}>
      <div className="flex items-center gap-1.5 mb-1"><Icon size={13} color={color} /><span style={{ fontSize: 11, color: COLORS.muted }}>{label}</span></div>
      <div className="num" style={{ fontSize: 15.5, fontWeight: 700, color: COLORS.ink }}>{fmt(value)}</div>
    </Glass>
  );
}

function TxnRow({ t: x, lang, showDate, delay = 0 }) {
  const meta = x.type === "expense" ? CATS[x.category] : null;
  const Icon = x.type === "expense" ? meta?.icon || MoreHorizontal : INCOME_CATS[x.category]?.icon || Gift;
  const color = x.type === "expense" ? meta?.color || COLORS.muted : COLORS.income;
  const catLabel = (x.type === "expense" ? CATS[x.category] : INCOME_CATS[x.category])?.label[lang] || x.category;
  const note = x.note?.[lang];
  return (
    <Glass className="flex items-center gap-3 rounded-xl p-2.5 anim-fadeup" style={{ borderRadius: 14, animationDelay: `${delay}s` }}>
      <div className="flex items-center justify-center rounded-full flex-shrink-0" style={{ width: 36, height: 36, background: `${color}26` }}><Icon size={16} color={color} /></div>
      <div className="flex-1 min-w-0">
        <div style={{ fontSize: 13.5, color: COLORS.ink, fontWeight: 500 }}>{catLabel}</div>
        {(note || showDate) && <div style={{ fontSize: 11, color: COLORS.muted }}>{note} {note && showDate ? "·" : ""} {showDate ? x.date : ""}</div>}
      </div>
      <div className="num" style={{ fontSize: 14, fontWeight: 600, color: x.type === "income" ? COLORS.income : COLORS.expense }}>{x.type === "income" ? "+" : "-"}{fmt(x.amount)}</div>
    </Glass>
  );
}
