# Stage 1
FROM mcr.microsoft.com/dotnet/core-nightly/sdk:3.0.100-preview9 as build
WORKDIR /app

COPY src src
RUN dotnet build src/MyWeb

# Stage 2
FROM build as publish
WORKDIR /app

RUN dotnet publish src/MyWeb -c Release -o /app -r linux-x64

# Stage 3
FROM mcr.microsoft.com/dotnet/core-nightly/runtime:3.0.0-preview9 AS runtime

ENV DOTNET_USE_POLLING_FILE_WATCHER=true
# ENV PORT=443
# ENV ASPNETCORE_URL=https://+:${PORT}
ENV Kestrel__Certificates__Default__Path=/app/Cert/cert-aspnetcore.pfx
ENV Kestrel__Certificates__Default__Password=1234

WORKDIR /app
COPY --from=publish /app .

CMD dotnet MyWeb.dll --urls https://+:443