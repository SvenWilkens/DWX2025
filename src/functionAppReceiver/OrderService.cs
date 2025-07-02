using System.Net;
using System.Text.Json;
using functionApp.Dto;
using functionApp.logic;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace functionApp;

public class OrderService(ILogger<OrderService> logger, IServiceBusSenderProvider serviceBusSenderProvider)
{
    [Function("ReceiveOrder")]
    
        public async Task<HttpResponseData> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = "Orderservice/Order/receive")] HttpRequestData req)
        {
            logger.LogInformation("HTTP POST empfangen");

            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();

            Kundendaten? daten;

            try
            {
                daten = JsonSerializer.Deserialize<Kundendaten>(requestBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            }
            catch
            {
                var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
                await badRequest.WriteStringAsync("Ungültiges JSON.");
                return badRequest;
            }

            if (daten == null || string.IsNullOrWhiteSpace(daten.Kundennummer) || string.IsNullOrWhiteSpace(daten.Artikel) || daten.Preis <= 0)
            {
                var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
                await badRequest.WriteStringAsync("Fehlende oder ungültige Felder.");
                return badRequest;
            }

        await serviceBusSenderProvider.SendMessageAsync(requestBody);


        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(new
        {
            Nachricht = "Daten erfolgreich empfangen",
            Daten = daten
        });

        return response;
        }
}



