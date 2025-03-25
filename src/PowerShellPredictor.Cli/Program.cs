using System.Management.Automation.Subsystem.Prediction;
using PowerShellPredictor;

var predictionContext = PredictionContext.Create(args[0]);
var predictionClient = new PredictionClient("PowerShellPredictor.Cli", PredictionClientKind.Terminal);

var predictor = new KnownCommandsPredictor();
var suggestionPackage = predictor.GetSuggestion(predictionClient, predictionContext, CancellationToken.None);

suggestionPackage.SuggestionEntries?.ForEach(suggestion => Console.WriteLine(suggestion.SuggestionText));
