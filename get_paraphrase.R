if (!require("httr")) {
  install.packages("httr")
}
if (!require("jsonlite")) {
  install.packages("jsonlite")
}

library(httr)
library(jsonlite)

# 检查输入参数
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  stop("请提供一个文本文件作为输入。")
}

input_file <- args[1]

# 读取文本文件
data <- read.csv(input_file, stringsAsFactors = FALSE, header = TRUE)

# 初始化一个空的向量来存储释义
explanations <- vector("character", length = nrow(data))

# 遍历第一列的每个单词
for (i in 1:nrow(data)) {
  word <- data[i, 1]
  print(word)
  
  # 构建URL
  url <- paste0("http://dict.youdao.com/suggest?num=1&doctype=json&q=", word)
  
  # 发送GET请求
  response <- GET(url)
  
  # 解析JSON响应
  content <- content(response, "text", encoding = "UTF-8")
  json_data <- fromJSON(content)
  
  # 提取释义
  if (!is.null(json_data$data$entries) && length(json_data$data$entries) > 0) {
    explanations[i] <- json_data$data$entries[[1]]
  } else {
    explanations[i] <- NA
  }
}

# 将释义写入第二列
data$Explanation <- explanations

# 保存结果到原文件
write.table(data, input_file, row.names = FALSE, sep = "\t", quote = FALSE)