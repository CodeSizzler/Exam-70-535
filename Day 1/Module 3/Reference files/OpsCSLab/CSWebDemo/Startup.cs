using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(CSWebDemo.Startup))]
namespace CSWebDemo
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
