# Установка рабочего каталога
setwd("C:/Users/akozyreva/Desktop/hw3-R")
print(getwd())

# Загрузка необходимых пакетов
library(readr)
library(dplyr)
library(tidyr)
library(tibble)
library(ggplot2)
library(randomForest)
library(pROC)

# Загрузка данных из файлов
control <- read.delim("control_genus.txt", row.names = 1, check.names = FALSE)
vzk <- read.delim("vzk_genus.txt", row.names = 1, check.names = FALSE)

# Добавление меток групп
control$Group <- 'Control'
vzk$Group <- 'VZK'

# Преобразование row names в отдельный столбец для последующего объединения
control <- control %>%
  rownames_to_column("SampleID")

vzk <- vzk %>%
  rownames_to_column("SampleID")

# Объединение данных
combined_data <- bind_rows(control, vzk)

# Проверка данных после объединения
str(combined_data)

# Преобразование данных в длинный формат для анализа
long_data <- combined_data %>%
  pivot_longer(cols = -c(SampleID, Group), names_to = "Genus", values_to = "Abundance")

# Проверка данных после преобразования
head(long_data)

# Дополнительные шаги для анализа и визуализации:??

# Убедимся, что столбцы Abundance имеют числовой тип
long_data$Abundance <- as.numeric(long_data$Abundance)

# Проверка нормальности распределения для каждого таксона в каждой группе.функция shapiro.test() - не может обрабатывать группы, в которых все значения одинаковы (например, все равны нулю).исключить такие группы из анализа нормальности
shapiro_test_results <- long_data %>%
  group_by(Genus, Group) %>%
  filter(var(Abundance) != 0) %>%
  summarize(shapiro_p = shapiro.test(Abundance)$p.value)

# Применение теста Вилкоксона для сравнения групп по каждому таксону
wilcox_test_results <- long_data %>%
  group_by(Genus) %>%
  summarize(wilcox_p = wilcox.test(Abundance[Group == 'Control'], Abundance[Group == 'VZK'])$p.value)

# Коррекция p-значений методом FDR
wilcox_test_results <- wilcox_test_results %>%
  mutate(pval_adj = p.adjust(wilcox_p, method = 'fdr'))

# Оставляем только значимые результаты (скорректированное p-значение < 0.05)
significant_results <- wilcox_test_results %>%
  filter(pval_adj < 0.05)

# Построение boxplot для визуализации различий между группами по значимым таксонам
library(ggplot2)
significant_taxa <- significant_results$Genus

for (taxon in significant_taxa) {
  p <- ggplot(long_data %>% filter(Genus == taxon), aes(x = Group, y = Abundance)) +
    geom_boxplot() +
    ggtitle(paste("Boxplot for", taxon)) +
    theme_minimal()
  ggsave(filename = paste("boxplot_", taxon, ".jpeg", sep = ""), plot = p, width = 7, height = 7)
}

# Разделение данных на обучающую и тестовую выборки
set.seed(123)
training_indices <- sample(seq_len(nrow(long_data)), size = 0.7 * nrow(long_data))
training_data <- long_data[training_indices, ]
testing_data <- long_data[-training_indices, ]

# Обучение модели Random Forest для классификации здоровых и больных
library(randomForest)

# Проверим уникальные значения переменной Group
unique(training_data$Group)
# Сделаем Group фактором. то есть факторы для модели "labels" это значения "Control" "VZK", которые лежат внутри переменной "Group" 
training_data$Group <- as.factor(training_data$Group)
str(training_data$Abundance)

rf_model <- randomForest(Group ~ Abundance + Genus, data = training_data)

# Оценка качества модели
predictions <- predict(rf_model, newdata = testing_data)
confusion_matrix <- table(testing_data$Group, predictions)
print(confusion_matrix)

# ROC-кривая и другие метрики
library(pROC)
roc_curve <- roc(testing_data$Group, as.numeric(predictions))
plot(roc_curve)

# Вывод AUC
auc(roc_curve)