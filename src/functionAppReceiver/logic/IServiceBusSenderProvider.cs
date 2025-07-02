namespace functionApp.logic
{
    public interface IServiceBusSenderProvider
    {
        Task SendMessageAsync(string messageBody);
    }
}