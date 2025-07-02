using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Configuration;

namespace functionApp.logic;

public class ServiceBusSenderProvider : IServiceBusSenderProvider
{
    private readonly ServiceBusSender _sender;

    public ServiceBusSenderProvider(IConfiguration configuration)
    {
        var connectionString = configuration["serviceBusConnection"];
        var queueName = configuration["QueueName"];

        var client = connectionString != null && connectionString.Contains("SharedAccessKey")
           ? new ServiceBusClient(connectionString)
           : new ServiceBusClient(connectionString, new DefaultAzureCredential());
        _sender = client.CreateSender(queueName);
    }

    public async Task SendMessageAsync(string messageBody)
    {
        var message = new ServiceBusMessage(messageBody);
        await _sender.SendMessageAsync(message);
    }
}



