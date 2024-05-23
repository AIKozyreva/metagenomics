#///raw files in th folder "raw".

library(dplyr)
library(reshape2)
library(ggplot2)
library(randomForest)
library(caret)
library(ROCR)

setwd("C:/Users/akozyreva/Desktop/hw3-R")
print(getwd())

control <- read.delim("control_genus.txt", row.names = 1, check.names = FALSE)
vzk <- read.delim("vzk_genus.txt", row.names = 1, check.names = FALSE)

control$label <- 'Control'
vzk$label <- 'VZK'
combined <- rbind(control, vzk)
str(combined)

control <- rownames(combined[which(combined$label == 'Control'),])
case <- rownames(combined[which(combined$label == 'VZK'),])

shapiro_control <- shapiro.test(combined[control, 1])
shapiro_case <- shapiro.test(combined[case, 1])
wilcoxRes <- matrix(ncol = 3, nrow = 0)
for (i in colnames(combined)[-ncol(combined)]) {
  wt <- wilcox.test(combined[case, i], combined[control, i])
  wilcoxRes <- rbind(wilcoxRes, c(i, wt$statistic, wt$p.value))
}

wilcoxPvalAdj <- p.adjust(wilcoxRes[, 3], method = 'fdr')
wilcoxRes <- cbind(wilcoxRes, wilcoxPvalAdj)
colnames(wilcoxRes) <- c('tax', 'stat', 'pval', 'pval_adj')
wilcoxRes <- as.data.frame(wilcoxRes)
wilcoxRes$pval <- round(as.numeric(as.character(wilcoxRes$pval)), 3)
wilcoxRes$pval_adj <- round(as.numeric(as.character(wilcoxRes$pval_adj)), 3)
wilcoxResSign <- wilcoxRes[which(wilcoxRes$pval_adj < 0.05), ]
print(wilcoxResSign)

dfGG <- combined[, c(as.character(wilcoxResSign$tax), 'label')]
dfGG <- melt(dfGG, id.vars = 'label')
plotBplot <- ggplot(dfGG, aes(x = variable, y = value, fill = label)) +
  geom_boxplot(outlier.colour = "red", outlier.shape = 16, outlier.alpha = 0.5, outlier.size = 0, notch = FALSE) +
  geom_jitter(alpha = 0.5, color = 'blue', size = 2.5) +  # Изменение цвета на зеленый и размера на 2.5
  scale_x_discrete(guide = guide_axis(angle = 90)) +
  theme_bw()
print(plotBplot)
dev.off()

if (!"sample_name" %in% colnames(combined)) {
  combined$sample_name <- rownames(combined)
}

set.seed(123)
train_index <- createDataPartition(y = combined$label, p = 0.8, list = FALSE)
train_set <- combined[train_index, ]
test_set <- combined[-train_index, ]

modRF <- randomForest(x = train_set[, -ncol(train_set)], y = as.factor(train_set$label), ntree = 500)
imp <- as.data.frame(importance(modRF))
imp <- cbind(rownames(imp), imp)
imp <- imp[order(imp$MeanDecreaseGini, decreasing = TRUE), ]

varImpPlot(modRF)
dev.off()

predictionTree <- predict(modRF, newdata = test_set[, -ncol(test_set)], type = 'prob')
predictionTreePerc <- as.data.frame(100 * predictionTree)
predictionTreePerc <- cbind(rownames(test_set), predictionTreePerc)
predictionTree <- predict(modRF, newdata = test_set[, -ncol(test_set)])
predictionTreePerc <- cbind(predictionTreePerc, predictionTree)
colnames(predictionTreePerc)[1] <- 'sample_name'
predictionTreePerc <- merge(predictionTreePerc, combined[, c('sample_name', 'label')], by = 'sample_name')

confmatRF <- confusionMatrix(data = as.factor(predictionTreePerc$predictionTree), reference = as.factor(predictionTreePerc$label))
print(confmatRF)

prediction_for_roc_curve <- predict(modRF, newdata = test_set[, -ncol(test_set)], type = 'prob')
classes <- levels(as.factor(predictionTreePerc$label))
pred <- prediction(prediction_for_roc_curve[, 2], predictionTreePerc$label)
perf <- performance(pred, "tpr", "fpr")
aucRF <- performance(pred, "auc")
plot(perf, main = "ROC Curve")


