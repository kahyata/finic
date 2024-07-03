import pandas as pd
from datetime import datetime
import tkinter as tk
from tkinter import messagebox, simpledialog

class Transaction:
    def __init__(self, date, amount, category, description=""):
        self.date = date
        self.amount = amount
        self.category = category
        self.description = description

class FinanceModel:
    def __init__(self):
        self.transactions = []
        self.savings = 0
        self.budget_allocation = {'needs': 0, 'wants': 0, 'savings': 0}

    def set_budget_allocation(self, needs_percent, wants_percent, savings_percent):
        total_percent = needs_percent + wants_percent + savings_percent
        if total_percent != 100:
            return False
        self.budget_allocation['needs'] = needs_percent
        self.budget_allocation['wants'] = wants_percent
        self.budget_allocation['savings'] = savings_percent
        return True

    def add_income(self, amount):
        needs_amount = amount * (self.budget_allocation['needs'] / 100)
        wants_amount = amount * (self.budget_allocation['wants'] / 100)
        savings_amount = amount * (self.budget_allocation['savings'] / 100)

        self.transactions.append(Transaction(datetime.now(), needs_amount, "Needs", "Allocated for needs"))
        self.transactions.append(Transaction(datetime.now(), wants_amount, "Wants", "Allocated for wants"))
        self.add_savings(savings_amount)

    def add_transaction(self, transaction):
        self.transactions.append(transaction)

    def add_savings(self, amount):
        self.savings += amount

    def generate_report(self):
        data = [{
            'Date': t.date.strftime('%Y-%m-%d'),
            'Amount': t.amount,
            'Category': t.category,
            'Description': t.description
        } for t in self.transactions]
        
        df = pd.DataFrame(data)
        return df

    def print_report(self):
        df = self.generate_report()
        report = "Monthly Finance History\n" + df.to_string(index=False) + f"\n\nTotal Savings: {self.savings}"
        total_income = df[df['Amount'] > 0]['Amount'].sum()
        total_expenses = df[df['Amount'] < 0]['Amount'].sum()
        report += f"\nTotal Income: {total_income}"
        report += f"\nTotal Expenses: {total_expenses}"
        report += f"\nNet Balance: {total_income + total_expenses + self.savings}"
        return report

class FinanceApp:
    def __init__(self, root):
        self.finance = FinanceModel()
        
        self.root = root
        self.root.title("Finance Manager")

        self.frame = tk.Frame(root)
        self.frame.pack(pady=20)

        self.budget_btn = tk.Button(self.frame, text="Set Budget Allocation", command=self.set_budget_allocation)
        self.budget_btn.grid(row=0, column=0, padx=5, pady=5)

        self.income_btn = tk.Button(self.frame, text="Add Income", command=self.add_income)
        self.income_btn.grid(row=0, column=1, padx=5, pady=5)

        self.expense_btn = tk.Button(self.frame, text="Add Expense", command=self.add_expense)
        self.expense_btn.grid(row=0, column=2, padx=5, pady=5)

        self.report_btn = tk.Button(self.frame, text="Generate Report", command=self.generate_report)
        self.report_btn.grid(row=0, column=3, padx=5, pady=5)

    def set_budget_allocation(self):
        needs_percent = simpledialog.askfloat("Input", "Enter percentage for needs:")
        wants_percent = simpledialog.askfloat("Input", "Enter percentage for wants:")
        savings_percent = simpledialog.askfloat("Input", "Enter percentage for savings:")
        
        if self.finance.set_budget_allocation(needs_percent, wants_percent, savings_percent):
            messagebox.showinfo("Success", "Budget allocation set successfully.")
        else:
            messagebox.showerror("Error", "Percentages must add up to 100.")

    def add_income(self):
        amount = simpledialog.askfloat("Input", "Enter income amount:")
        if amount is not None:
            self.finance.add_income(amount)
            messagebox.showinfo("Success", f"Income of {amount} added and allocated to needs, wants, and savings.")

    def add_expense(self):
        amount = simpledialog.askfloat("Input", "Enter expense amount:")
        if amount is not None:
            amount = -amount  # Make expense negative
            category = simpledialog.askstring("Input", "Enter expense category (Needs/Wants):").capitalize()
            description = simpledialog.askstring("Input", "Enter expense description:")

            if category in ["Needs", "Wants"]:
                self.finance.add_transaction(Transaction(datetime.now(), amount, category, description))
                messagebox.showinfo("Success", f"Expense of {amount} added to {category}.")
            else:
                messagebox.showerror("Error", "Invalid category. Please enter 'Needs' or 'Wants'.")

    def generate_report(self):
        report = self.finance.print_report()
        report_window = tk.Toplevel(self.root)
        report_window.title("Finance Report")
        report_text = tk.Text(report_window, wrap=tk.WORD)
        report_text.insert(tk.END, report)
        report_text.pack(expand=True, fill=tk.BOTH)
        report_text.config(state=tk.DISABLED)

if __name__ == "__main__":
    root = tk.Tk()
    app = FinanceApp(root)
    root.mainloop()
