package com.mypoysha.config;

import com.mypoysha.entity.Category;
import com.mypoysha.repo.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final CategoryRepository categoryRepository;

    @Override
    public void run(String... args) throws Exception {
        if (categoryRepository.count() == 0) {
            List<Category> categories = List.of(
                    new Category("food", "expense", "খাবার", "Food", "UtensilsCrossed", "#FF6F61", false),
                    new Category("rent", "expense", "বাসাভাড়া", "Rent", "HomeIcon", "#D89A4E", false),
                    new Category("transport", "expense", "যাতায়াত", "Transport", "Bus", "#6FA0E8", false),
                    new Category("bills", "expense", "বিল", "Bills", "Zap", "#E8B84B", false),
                    new Category("shopping", "expense", "কেনাকাটা", "Shopping", "ShoppingBag", "#B27FE8", false),
                    new Category("health", "expense", "স্বাস্থ্য", "Health", "HeartPulse", "#E87FB0", false),
                    new Category("education", "expense", "শিক্ষা", "Education", "GraduationCap", "#2FBF9F", false),
                    new Category("other", "expense", "অন্যান্য", "Other", "MoreHorizontal", "#8B7D93", false),
                    new Category("loan_given", "expense", "ধার দেওয়া", "Loan given", "HandCoins", "#E8B84B", true),
                    new Category("loan_repay_expense", "expense", "ধার শোধ করলাম", "Loan repaid by me", "HandCoins", "#FF6F61", true),
                    
                    new Category("salary", "income", "বেতন", "Salary", "Briefcase", "#2FBF9F", false),
                    new Category("business", "income", "ব্যবসা", "Business", "TrendingUp", "#2FBF9F", false),
                    new Category("other_income", "income", "অন্যান্য আয়", "Other income", "Gift", "#2FBF9F", false),
                    new Category("loan_taken", "income", "ধার নেওয়া", "Loan taken", "HandCoins", "#6FA0E8", true),
                    new Category("loan_repay_income", "income", "ধার ফেরত পেলাম", "Loan repaid to me", "HandCoins", "#2FBF9F", true)
            );

            categoryRepository.saveAll(categories);
            System.out.println("Seeded categories into database.");
        }
    }
}

