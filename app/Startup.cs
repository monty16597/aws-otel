// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

// using Amazon.XRay.Recorder.Core;
// using Amazon.XRay.Recorder.Core.Internal.Entities;
// using Amazon.XRay.Recorder.Handlers.AwsSdk;
// using Amazon.XRay.Recorder.Handlers.AspNetCore;

namespace integration_test_app;

public class Startup
{
    public Startup(IConfiguration configuration)
    {
        this.Configuration = configuration;
        // Enable AWS X-Ray
        // AWSXRayRecorder.Instance.BeginSegment("MyApp");

        // Register AWS SDK instrumentation
        // AWSSDKHandler.RegisterXRayForAllServices();
    }

    public IConfiguration Configuration { get; }

    // This method gets called by the runtime. Use this method to add services to the container.
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddControllers();
        // Services.AddAWSXRay();

        AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);
    }

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }
        
        // app.UseXRay("MyApp");

        app.UseRouting();

        app.UseAuthorization();

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers();
        });
    }
}
