class EvaluationMetrics {
  final double auroc;
  final double auprc;
  final double calibrationScore;
  final ConfusionMatrix confusionMatrix;

  EvaluationMetrics({
    required this.auroc,
    required this.auprc,
    required this.calibrationScore,
    required this.confusionMatrix,
  });
}

class ConfusionMatrix {
  final int truePositives;
  final int falsePositives;
  final int trueNegatives;
  final int falseNegatives;

  ConfusionMatrix({
    required this.truePositives,
    required this.falsePositives,
    required this.trueNegatives,
    required this.falseNegatives,
  });

  double get accuracy {
    final total =
        truePositives + falsePositives + trueNegatives + falseNegatives;
    return (truePositives + trueNegatives) / total;
  }

  double get precision {
    return truePositives / (truePositives + falsePositives);
  }

  double get recall {
    return truePositives / (truePositives + falseNegatives);
  }

  double get f1Score {
    final precision = this.precision;
    final recall = this.recall;
    return 2 * (precision * recall) / (precision + recall);
  }
}

class FeatureImportance {
  final String featureName;
  final double importance;
  final String description;

  FeatureImportance({
    required this.featureName,
    required this.importance,
    required this.description,
  });
}
