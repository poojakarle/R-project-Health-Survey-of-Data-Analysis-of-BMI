
# Load the NHANES and dplyr packages
# .... YOUR CODE FOR TASK 1 ....

# Load the NHANESraw data
....("NHANESraw")

# Take a glimpse at the contents
# .... YOUR CODE FOR TASK 1 ....

library(testthat) 
library(IRkernel.testthat)

run_tests(
    test_that("the dataset is loaded correctly", {
        expect_equal(
            nrow(NHANESraw), 
            20293,
            info = "Did you load the 'NHANESraw' dataset?"
        )
        expect_true(
            "data.frame" %in% class(NHANESraw),
            info = "Did you load the 'NHANESraw' dataset? Read the data() documentation for help.")
    })
)

# Load the ggplot2 package
# .... YOUR CODE FOR TASK 2 ....

# Use mutate to create a 4-year weight variable and call it WTMEC4YR
NHANESraw <- NHANESraw %>% mutate(.... = ..../2)

# Calculate the sum of this weight variable
NHANESraw %>% summarize(....)

# Plot the sample weights using boxplots, with Race1 on the x-axis
ggplot(...., aes(x = ...., y = ....)) + ....

stud_plot <- last_plot()
soln_plot <- ggplot(NHANESraw, aes(x = Race1, y = WTMEC4YR)) + geom_boxplot()

run_tests({
    test_that("WTMEC4YR is correct", {
    expect_true("WTMEC4YR" %in% colnames(NHANESraw), 
        info = "Did you name the new column WTMEC4YR?")
    expect_equal(sum(NHANESraw$WTMEC4YR), 304267200,
                info = "The weights do not add up correctly. Is `WTMEC4YR = WTMEC2YR/2`?")
    })
    test_that("plot is drawn correctly", {
        expect_s3_class(stud_plot, "ggplot")
        expect_identical(
            stud_plot$data,
            soln_plot$data,
            info = 'The plot data is incorrect. Did you use `NHANESraw` with the new column `WTMEC4YR`?'
        )   
        expect_identical(
            deparse(stud_plot$mapping$x),
            deparse(soln_plot$mapping$x),
            info = 'The `x` aesthetic is incorrect. Did you map it to `Race1`?'
        )      
        expect_identical(
            deparse(stud_plot$mapping$y),
            deparse(soln_plot$mapping$y),
            info = 'The `y` aesthetic is incorrect. Did you map it to `WTMEC4YR`?'
        )  
        expect_identical(
            class(stud_plot$layers[[1]]$geom)[1],
            class(soln_plot$layers[[1]]$geom)[1],
            info = 'There is no boxplot layer. Did you call `geom_boxplot()`?'
        )
    })
})

# Load the survey package
# .... YOUR CODE FOR TASK 3 ....

# Specify the survey design
nhanes_design <- svydesign(
    data = NHANESraw,
    strata = ~....,
    id = ~....,
    nest = ....,
    weights = ~....)

# Print a summary of this design
summary(....)

soln_nhanes_design <- svydesign(data = NHANESraw, 
                           strata = ~SDMVSTRA, 
                           id = ~SDMVPSU, 
                           nest = TRUE, # If nest = FALSE, student will get an error telling them to set nest = TRUE
                           weights = ~WTMEC4YR)

run_tests({
    test_that("the study design is correct", {
        expect_s3_class(nhanes_design, "survey.design2")
        expect_equal(
            names(nhanes_design$strata),
            names(soln_nhanes_design$strata),
            info = "The strata variable is not correct. Did you specify `strata = ~SDMVSTRA`?"
        )
        expect_equal(
            names(nhanes_design$cluster),
            names(soln_nhanes_design$cluster),
            info = "The id variable is not correct. Did you specify `id = ~SDMVPSU`?"
        )
        expect_equal(
            names(nhanes_design$allprob),
            names(soln_nhanes_design$allprob),
            info = "The weight variable is not correct. Did you specify `weights = ~WTMEC4YR`?"
        )
        })
})

# Select adults of Age >= 20 with subset
nhanes_adult <- ....(nhanes_design, ....)

# Print a summary of this subset
# .... YOUR CODE FOR TASK 4 ....

# Compare the number of observations in the full data to the adult data
....(nhanes_design)
....(nhanes_adult)

soln_nhanes_adult <- subset(soln_nhanes_design, Age >= 20)

run_tests({
    test_that("the subset design is correct", {
        expect_s3_class(nhanes_adult, "survey.design2")
        expect_equal(
            nrow(nhanes_adult),
            nrow(soln_nhanes_adult),
            info = "The number of observations in `nhanes_adult` is not correct. Did you specify `Age >= 20`?"
        )
        })
})

# Calculate the mean BMI in NHANESraw
bmi_mean_raw <- NHANESraw %>% 
    filter(Age >= 20) %>%
    summarize(mean(...., na.rm = TRUE))
bmi_mean_raw

# Calculate the survey-weighted mean BMI of US adults
bmi_mean <- svymean(~...., design = nhanes_adult, na.rm = TRUE)
bmi_mean

# Draw a weighted histogram of BMI in the US population
NHANESraw %>% 
  filter(....) %>%
    ggplot(mapping = aes(x = ...., weight = ....)) + 
    ....()+
    geom_vline(xintercept = coef(bmi_mean), color="red")

stud_plot <- last_plot()

soln_bmi_mean_raw <- NHANESraw %>% 
    filter(Age >= 20) %>%
    summarize(mean(BMI, na.rm=TRUE))

soln_bmi_mean <- svymean(~BMI, design = soln_nhanes_adult, na.rm = TRUE)

soln_plot <- NHANESraw %>% 
  filter(Age >= 20) %>%
    ggplot(mapping = aes(x = BMI, weight = WTMEC4YR)) + 
    geom_histogram()+
    geom_vline(xintercept = coef(bmi_mean), color="red")

run_tests({
    test_that("the raw mean is correct", {
        expect_true(
            !is.na(bmi_mean_raw[[1]]),
            info = "`bmi_mean_raw` contains `NA`. Did you specify `na.rm=TRUE` in `summarize()`?"
        )
        expect_equal(
            soln_bmi_mean_raw[[1]],
            bmi_mean_raw[[1]],
            info = "`bmi_mean_raw` is not correct. Did you use `filter(Age >= 20)` and take the `mean` of `BMI`?"
        )
        expect_false(
            names(bmi_mean_raw)=="mean(BMI, na.rm = T)",
            info = "Careful! You specified `na.rm = T` but it is preferred to use `na.rm = TRUE`."
        )
    })
    test_that("the survey mean is correct", {
        expect_equal(
            as.data.frame(soln_bmi_mean),
            as.data.frame(bmi_mean),
            info = "`bmi_mean` is not correct. Did you use `svymean()` correctly using `nhanes_adult` design?"
        ) 
    })
    test_that("plot is drawn correctly", {
        expect_s3_class(stud_plot, "ggplot")
        expect_identical(
            stud_plot$data,
            soln_plot$data,
            info = 'The plot data is incorrect. Did you use `NHANESraw` after filtering `Age >= 20`?'
        )   
        expect_identical(
            deparse(stud_plot$mapping$x),
            deparse(soln_plot$mapping$x),
            info = 'The `x` aesthetic is incorrect. Did you map it to `BMI`?'
        )      
        expect_identical(
            deparse(stud_plot$mapping$weight),
            deparse(soln_plot$mapping$weight),
            info = 'The `weight` aesthetic is incorrect. Did you map it to `WTMEC4YR`?'
        )  
        expect_identical(
            class(stud_plot$layers[[1]]$geom)[1],
            class(soln_plot$layers[[1]]$geom)[1],
            info = 'There is no histogram layer. Did you call `geom_histogram()`?'
        )
    })
})

# Load the broom library
# .... YOUR CODE FOR TASK 6 ....

# Make a boxplot of BMI stratified by physically active status
NHANESraw %>% 
  filter(Age>=20) %>%
# .... YOUR CODE FOR TASK 6 ....

# Conduct a t-test comparing mean BMI between physically active status
survey_ttest <- svyttest(....~...., design = ....)

# Use broom to show the tidy results
# .... YOUR CODE FOR TASK 6 ....

stud_plot <- last_plot()
soln_plot <- NHANESraw %>% 
  filter(Age>=20) %>%
    ggplot(mapping = aes(x = PhysActive, y = BMI, weight = WTMEC4YR)) + 
    geom_boxplot()

soln_ttest <- tidy(svyttest(BMI~PhysActive, design = soln_nhanes_adult))
stud_ttest <- tidy(survey_ttest)

run_tests({
    test_that("plot is drawn correctly", {
        expect_s3_class(stud_plot, "ggplot")
        expect_identical(
            stud_plot$data,
            soln_plot$data,
            info = 'The plot data is incorrect. Did you use `NHANESraw` with `filter(Age>=20)`?'
        )   
        expect_identical(
            deparse(stud_plot$mapping$x),
            deparse(soln_plot$mapping$x),
            info = 'The `x` aesthetic is incorrect. Did you map it to `PhysActive`?'
        )      
        expect_identical(
            deparse(stud_plot$mapping$y),
            deparse(soln_plot$mapping$y),
            info = 'The `y` aesthetic is incorrect. Did you map it to `BMI`?'
        )  
        expect_identical(
            deparse(stud_plot$mapping$weight),
            deparse(soln_plot$mapping$weight),
            info = 'The `weight` aesthetic is incorrect. Did you map it to `WTMEC4YR`?'
        )  
        expect_identical(
            class(stud_plot$layers[[1]]$geom)[1],
            class(soln_plot$layers[[1]]$geom)[1],
            info = 'There is no boxplot layer. Did you call `geom_boxplot()`?'
        )
    })
    test_that("t test is correct", {
        expect_equal(
            as.data.frame(soln_ttest),
            as.data.frame(stud_ttest),
            info = 'The t-test result is incorrect. Did you use the arguments `BMI~PhysActive` and `design=nhanes_adult`?'
        )
    })
})

# Estimate the proportion who are physically active by current smoking status
phys_by_smoke <- svyby(~...., by = ~...., 
                       FUN = ...., 
                       design = nhanes_adult, 
                       keep.names = FALSE)

# Print the table
phys_by_smoke

# Plot the proportions
ggplot(data = phys_by_smoke, 
       aes(x = ...., y = PhysActiveYes, fill = SmokeNow)) +
 # .... YOUR CODE FOR TASK 7 ....

stud_plot <- last_plot()
soln_plot <- ggplot(data = phys_by_smoke, 
       aes(y = PhysActiveYes, x = SmokeNow, fill = SmokeNow)) +
    geom_col() +
    ylab("Proportion Physically Active")

soln_phys_by_smoke <- svyby(~PhysActive, by = ~SmokeNow, 
                       FUN = svymean, 
                       design = soln_nhanes_adult, 
                       keep.names = FALSE)

run_tests({
    test_that("plot is drawn correctly", {
        expect_s3_class(stud_plot, "ggplot")
        expect_identical(
            stud_plot$data,
            soln_plot$data,
            info = 'The plot data is incorrect. Did you use `phys_by_smoke`?'
        )   
        expect_identical(
            deparse(stud_plot$mapping$x),
            deparse(soln_plot$mapping$x),
            info = 'The `x` aesthetic is incorrect. Did you map it to `SmokeNow`?'
        )      
        expect_identical(
            deparse(stud_plot$mapping$y),
            deparse(soln_plot$mapping$y),
            info = 'The `y` aesthetic is incorrect. Did you map it to `PhysActiveYes`?'
        )  
        expect_identical(
            deparse(stud_plot$mapping$fill),
            deparse(soln_plot$mapping$fill),
            info = 'The `fill` aesthetic is incorrect. Did you map it to `SmokeNow`?'
        )  
        expect_identical(
            class(stud_plot$layers[[1]]$geom)[1],
            class(soln_plot$layers[[1]]$geom)[1],
            info = 'There is no column plot layer. Did you call `geom_col()`?'
        )
        expect_identical(
            stud_plot$labels$y,
            soln_plot$labels$y,
            info = 'The y-label is incorrect, did you label it "Proportion Physically Active"'
        )
    })
    test_that("table is correct", {
        expect_true(
            "PhysActiveYes"%in%colnames(phys_by_smoke),
            info = 'The `svyby()` result is incorrect. Is the first argument `~PhysActive`?'
        )
        expect_true(
            "SmokeNow" == colnames(phys_by_smoke)[1],
            info = 'The `svyby()` result is incorrect. Did you set `by = ~SmokeNow`?'
        )
        expect_equivalent(
            as.data.frame(phys_by_smoke),
            as.data.frame(soln_phys_by_smoke),
            info = 'The `svyby()` result is incorrect. Did you use argument `FUN = svymean`?'
        )
    })
})

# Estimate mean BMI by current smoking status
BMI_by_smoke <- svyby(~...., by = ~...., 
                      FUN = ....,
                      design = nhanes_adult,
                      na.rm = TRUE)
BMI_by_smoke

# Plot the distribution of BMI by current smoking status
NHANESraw %>% 
  filter(Age>=20, !is.na(SmokeNow)) %>% 
# .... YOUR CODE FOR TASK 8 ....

stud_plot <- last_plot()
soln_plot <- NHANESraw %>% 
  filter(Age>=20, !is.na(SmokeNow)) %>%
    ggplot(mapping = aes(x = SmokeNow, y = BMI, weight = WTMEC4YR)) + 
    geom_boxplot()

soln_BMI_by_smoke <- svyby(~BMI, by = ~SmokeNow, 
      FUN = svymean, 
      design = soln_nhanes_adult, 
      na.rm = TRUE)

run_tests({
    test_that("plot is drawn correctly", {
        expect_s3_class(stud_plot, "ggplot")
        expect_identical(
            stud_plot$data,
            soln_plot$data,
            info = 'The plot data is incorrect. Did you use `NHANESraw` with `filter(Age>=20, , !is.na(SmokeNow))`?'
        )   
        expect_identical(
            deparse(stud_plot$mapping$x),
            deparse(soln_plot$mapping$x),
            info = 'The `x` aesthetic is incorrect. Did you map it to `SmokeNow`?'
        )      
        expect_identical(
            deparse(stud_plot$mapping$y),
            deparse(soln_plot$mapping$y),
            info = 'The `y` aesthetic is incorrect. Did you map it to `BMI`?'
        )  
        expect_identical(
            deparse(stud_plot$mapping$weight),
            deparse(soln_plot$mapping$weight),
            info = 'The `weight` aesthetic is incorrect. Did you map it to `WTMEC4YR`?'
        )  
        expect_identical(
            class(stud_plot$layers[[1]]$geom)[1],
            class(soln_plot$layers[[1]]$geom)[1],
            info = 'There is no boxplot layer. Did you call `geom_boxplot()`?'
        )
    })
    test_that("table is correct", {
        expect_true(
            "BMI"%in%colnames(BMI_by_smoke),
            info = 'The `svyby()` result is incorrect. Is the first argument `~BMI`?'
        )
        expect_true(
            "SmokeNow" == colnames(BMI_by_smoke)[1],
            info = 'The `svyby()` result is incorrect. Did you set `by = ~SmokeNow`?'
        )
        expect_equivalent(
            as.data.frame(BMI_by_smoke),
            as.data.frame(soln_BMI_by_smoke),
            info = 'The `svyby()` result is incorrect. Did you use argument `FUN = svymean`?'
        )
    })
})

# Plot the distribution of BMI by smoking and physical activity status
NHANESraw %>% 
  filter(Age>=20) %>% 
# .... YOUR CODE FOR TASK 9 ....

stud_plot <- last_plot()
soln_plot <- NHANESraw %>% 
  filter(Age>=20) %>%
    ggplot(mapping = aes(x = SmokeNow, 
                         y = BMI, 
                         weight = WTMEC4YR, 
                         color = PhysActive)) + 
    geom_boxplot()

run_tests({
    test_that("plot is drawn correctly", {
        expect_s3_class(stud_plot, "ggplot")
        expect_identical(
            stud_plot$data,
            soln_plot$data,
            info = 'The plot data is incorrect. Did you use `NHANESraw` with `filter(Age>=20)`?'
        )   
        expect_identical(
            deparse(stud_plot$mapping$x),
            deparse(soln_plot$mapping$x),
            info = 'The `x` aesthetic is incorrect. Did you map it to `SmokeNow`?'
        )      
        expect_identical(
            deparse(stud_plot$mapping$y),
            deparse(soln_plot$mapping$y),
            info = 'The `y` aesthetic is incorrect. Did you map it to `BMI`?'
        )  
        expect_identical(
            deparse(stud_plot$mapping$weight),
            deparse(soln_plot$mapping$weight),
            info = 'The `weight` aesthetic is incorrect. Did you map it to `WTMEC4YR`?'
        )  
        expect_identical(
            deparse(stud_plot$mapping$color),
            deparse(soln_plot$mapping$color),
            info = 'The `color` aesthetic is incorrect. Did you map it to `PhysActive`?'
        )  
        expect_identical(
            class(stud_plot$layers[[1]]$geom)[1],
            class(soln_plot$layers[[1]]$geom)[1],
            info = 'There is no boxplot layer. Did you call `geom_boxplot()`?'
        )
    })
})

# Fit a multiple regression model
mod1 <- svyglm(...., design = nhanes_adult)

# Tidy the model results
tidy_mod1 <- ....
tidy_mod1

# Calculate expected mean difference in BMI for activity within non-smokers
diff_non_smoke <- tidy_mod1 %>% 
    filter(term == ....) %>% 
    select(estimate)
diff_non_smoke

# Calculate expected mean difference in BMI for activity within smokers
diff_smoke <- tidy_mod1 %>% 
    filter(term %in% c(...., ....)) %>% 
    summarize(estimate = sum(estimate))
diff_smoke

soln_mod1 <- svyglm(BMI ~ PhysActive*SmokeNow, design = soln_nhanes_adult)
soln_tidy_mod1 <- tidy(soln_mod1)
soln_diff_non_smoke <- soln_tidy_mod1 %>% 
    filter(term=="PhysActiveYes") %>% 
    select(estimate)
soln_diff_smoke <- soln_tidy_mod1 %>% 
    filter(term%in%c("PhysActiveYes","PhysActiveYes:SmokeNowYes")) %>% 
    summarize(estimate = sum(estimate))

run_tests({
    test_that("the svyglm model is correct", {
    expect_true(
        "PhysActiveYes" %in% tidy_mod1$term,
        info = "The formula for `svyglm()` is not correct. Did you include `PhysActive` as a predictor?"
    )
    expect_true(
        "SmokeNowYes" %in% tidy_mod1$term,
        info = "The formula for `svyglm()` is not correct. Did you include `SmokeNow` as a predictor?"
    )
    expect_true(
        ("PhysActiveYes:SmokeNowYes" %in% tidy_mod1$term)|("SmokeNowYes:PhysActiveYes" %in% tidy_mod1$term),
        info = "The formula for `svyglm()` is not correct. Did you include the interaction term `PhysActive*SmokeNow` or `SmokeNow*PhysActive`?"
    )
    })
    test_that("the estimates are correct", {
    expect_equal(
        as.data.frame(diff_non_smoke),
        as.data.frame(soln_diff_non_smoke),
        info = "`diff_non_smoke` is incorrect. Did you use `filter(term=='PhysActiveYes')`?"
    )
    expect_equal(
        as.data.frame(diff_smoke),
        as.data.frame(soln_diff_smoke),
        info = "`diff_smoke` is incorrect. Did you use `filter(term%in%c('PhysActiveYes','PhysActiveYes:SmokeNowYes'))` or `filter(term%in%c('PhysActiveYes','SmokeNowYes:PhysActiveYes'))`?"

    )
    })
})

# Adjust mod1 for other possible confounders
mod2 <- ....(.... ~ PhysActive*SmokeNow + ...., 
               design = nhanes_adult)

# Tidy the output
....

soln <- tidy(svyglm(BMI ~ PhysActive*SmokeNow + Race1 + Alcohol12PlusYr + Gender, 
               design = soln_nhanes_adult))
stud <- tidy(mod2)

run_tests({
    test_that("the svyglm model is correct", {
        expect_identical(
            sort(soln$term),
            sort(stud$term),
            info = "The terms in the glm are incorrect. Did you add `Gender`, `Race1`, `Alcohol12PlusYr`?"
        )
    })
})

