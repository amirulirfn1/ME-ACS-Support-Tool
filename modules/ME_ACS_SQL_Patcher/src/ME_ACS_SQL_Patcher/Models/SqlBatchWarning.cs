namespace MagDbPatcher.Models;

public record SqlBatchWarning(
    string ScriptName,
    int BatchIndex,
    int BatchCount,
    int ErrorNumber,
    string ErrorMessage,
    string BatchPreview);
