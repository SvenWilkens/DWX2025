using functionApp.Dto;
using functionApp.logic;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;

namespace IncommingOrder;

public class EmailService(ILogger<EmailService> logger, IServiceBusSenderProvider serviceBusSenderProvider)
{
    private readonly IServiceBusSenderProvider _serviceBusSenderProvider = serviceBusSenderProvider;

    [Function("GenerateEmail")]
    public async Task<HttpResponseData> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = "emailService/Email/create")] HttpRequestData req)
    {
        logger.LogInformation("HTTP POST empfangen");

        var requestBody = await new StreamReader(req.Body).ReadToEndAsync();

        KundenInformation? daten;

        try
        {
            daten = JsonSerializer.Deserialize<KundenInformation>(requestBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }
        catch
        {
            var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
            await badRequest.WriteStringAsync("Ungültiges JSON.");
            return badRequest;
        }

        if (daten == null || string.IsNullOrWhiteSpace(daten.Kundennummer))
        {
            var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
            await badRequest.WriteStringAsync("Fehlende Kundennummer");
            return badRequest;
        }

        var mailRepository = new Dictionary<string, string>
        {
            { "12345", "sven-wilkens@outlook.de" },
            { "123456", "sven-wilkens@outlook.com" },
            { "DWX1", "demo-sven-wilkens@outlook.de" },
            { "DWX2", "demo-sven-wilkens@outlook.de" }
        };

     
        var email = mailRepository.GetValueOrDefault(daten.Kundennummer);
        if (string.IsNullOrWhiteSpace(email))
        {
            var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
            await notFoundResponse.WriteStringAsync($"Keine E-Mail-Adresse für die Kundennummer {daten.Kundennummer} gefunden.");
            return notFoundResponse;
        }

        var response = req.CreateResponse(HttpStatusCode.OK);
        
        await response.WriteAsJsonAsync(new
        {
            Email = email,
        });

        return response;
    }
}



