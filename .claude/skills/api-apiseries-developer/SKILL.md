---
name: api-fid-developer
description: Experto en la integración de API de terceros con autenticación adecuada, manejo de errores, limitación de velocidad y lógica de reintentos. Se utiliza para la integración de API REST, endpoints GraphQL, webhooks o servicios externos. Especializado en flujos OAuth, gestión de claves API, transformación de solicitudes/respuestas y desarrollo de clientes API robustos.
---

# API Integration Specialist

Asesoramiento experto para la integración de API externas en aplicaciones con patrones listos para producción, mejores prácticas de seguridad y un manejo integral de errores, en Type Script y JavaScript.

## When to Use This Skill

Utiliza esta habilidad cuando:
- Integres API de terceros (Stripe, Twilio, SendGrid, etc.)
- Desarrolles bibliotecas o adaptadores de cliente para API
- Implementes OAuth 2.0, claves API o autenticación JWT
- Configures webhooks e integraciones basadas en eventos
- Gestiones límites de velocidad, reintentos y disyuntores
- Transformes respuestas de API para su uso en aplicaciones
- Soluciones problemas de integración de API

## Core Integration Principles

### 1. Authentication & Security

**API Key Management:**
```javascript
// Store keys in environment variables, never in code
const apiClient = new APIClient({
  apiKey: process.env.SERVICE_API_KEY,
  baseURL: process.env.SERVICE_BASE_URL
});
```

**OAuth 2.0 Flow:**
```javascript
// Authorization Code Flow
const oauth = new OAuth2Client({
  clientId: process.env.CLIENT_ID,
  clientSecret: process.env.CLIENT_SECRET,
  redirectUri: process.env.REDIRECT_URI,
  scopes: ['read:users', 'write:data']
});

// Get authorization URL
const authUrl = oauth.getAuthorizationUrl();

// Exchange code for tokens
const tokens = await oauth.exchangeCode(code);
```

### 2. Request/Response Handling

**Standardized Request Structure:**
```javascript
async function makeRequest(endpoint, options = {}) {
  const defaultHeaders = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${apiKey}`,
    'User-Agent': 'MyApp/1.0.0'
  };

  const response = await fetch(`${baseURL}${endpoint}`, {
    ...options,
    headers: { ...defaultHeaders, ...options.headers }
  });

  if (!response.ok) {
    throw new APIError(response.status, await response.json());
  }

  return response.json();
}
```

**Response Transformation:**
```javascript
class APIClient {
  async getUser(userId) {
    const raw = await this.request(`/users/${userId}`);

    // Transform external API format to internal model
    return {
      id: raw.user_id,
      email: raw.email_address,
      name: `${raw.first_name} ${raw.last_name}`,
      createdAt: new Date(raw.created_timestamp)
    };
  }
}
```

### 3. Error Handling

**Structured Error Types:**
```javascript
class APIError extends Error {
  constructor(status, body) {
    super(`API Error: ${status}`);
    this.status = status;
    this.body = body;
    this.isAPIError = true;
  }

  isRateLimited() {
    return this.status === 429;
  }

  isUnauthorized() {
    return this.status === 401;
  }

  isServerError() {
    return this.status >= 500;
  }
}
```

**Retry Logic with Exponential Backoff:**
```javascript
async function retryWithBackoff(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (!error.isAPIError || !error.isServerError()) {
        throw error; // Don't retry client errors
      }

      if (i === maxRetries - 1) throw error;

      const delay = Math.pow(2, i) * 1000; // 1s, 2s, 4s
      await sleep(delay);
    }
  }
}
```

### 4. Rate Limiting

**Client-Side Rate Limiter:**
```javascript
class RateLimiter {
  constructor(maxRequests, windowMs) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.requests = [];
  }

  async acquire() {
    const now = Date.now();
    this.requests = this.requests.filter(t => now - t < this.windowMs);

    if (this.requests.length >= this.maxRequests) {
      const oldestRequest = this.requests[0];
      const waitTime = this.windowMs - (now - oldestRequest);
      await sleep(waitTime);
      return this.acquire();
    }

    this.requests.push(now);
  }
}

const limiter = new RateLimiter(100, 60000); // 100 requests per minute

async function rateLimitedRequest(endpoint, options) {
  await limiter.acquire();
  return makeRequest(endpoint, options);
}
```

### 5. Webhook Handling

**Webhook Verification:**
```javascript
function verifyWebhookSignature(payload, signature, secret) {
  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');

  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expectedSignature)
  );
}

app.post('/webhooks/stripe', express.raw({ type: 'application/json' }), (req, res) => {
  const signature = req.headers['stripe-signature'];

  if (!verifyWebhookSignature(req.body, signature, process.env.STRIPE_WEBHOOK_SECRET)) {
    return res.status(401).send('Invalid signature');
  }

  const event = JSON.parse(req.body);
  handleWebhookEvent(event);

  res.status(200).send('Received');
});
```

## Integration Patterns

### REST API Client Pattern

```javascript
class ServiceAPIClient {
  constructor(config) {
    this.apiKey = config.apiKey;
    this.baseURL = config.baseURL;
    this.timeout = config.timeout || 30000;
  }

  async request(method, endpoint, data = null) {
    const options = {
      method,
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json'
      },
      timeout: this.timeout
    };

    if (data) {
      options.body = JSON.stringify(data);
    }

    const response = await retryWithBackoff(() =>
      fetch(`${this.baseURL}${endpoint}`, options)
    );

    return response.json();
  }

  // Resource methods
  async getResource(id) {
    return this.request('GET', `/resources/${id}`);
  }

  async createResource(data) {
    return this.request('POST', '/resources', data);
  }

  async updateResource(id, data) {
    return this.request('PUT', `/resources/${id}`, data);
  }

  async deleteResource(id) {
    return this.request('DELETE', `/resources/${id}`);
  }
}
```

### Pagination Handling

```javascript
async function* fetchAllPages(endpoint, pageSize = 100) {
  let cursor = null;

  do {
    const params = new URLSearchParams({
      limit: pageSize,
      ...(cursor && { cursor })
    });

    const response = await apiClient.request('GET', `${endpoint}?${params}`);

    yield response.data;

    cursor = response.pagination?.next_cursor;
  } while (cursor);
}

// Usage
for await (const page of fetchAllPages('/users')) {
  processUsers(page);
}
```

## Best Practices

### Security
- Almacenar las claves API en variables de entorno o en la gestión de secretos.
- Usar HTTPS para todas las llamadas a la API.
- Verificar las firmas de los webhooks.
- Implementar la firma de solicitudes para operaciones sensibles.
- Rotar las claves API periódicamente.

### Reliability
- Implementar lógica de reintento con retroceso exponencial
- Gestionar adecuadamente los límites de velocidad
- Establecer tiempos de espera apropiados
- Utilizar disyuntores para servicios con fallos
- Registrar todas las interacciones de la API para la depuración

### Performance
- Almacenar en caché las respuestas cuando sea apropiado.
- Procesar las solicitudes por lotes cuando la API lo permita.
- Utilizar la transmisión de datos para respuestas grandes.
- Implementar la agrupación de conexiones.
- Monitorear el uso y los costos de la API.

### Monitoring
- Seguimiento de los tiempos de respuesta de la API
- Alertas sobre aumentos en la tasa de errores
- Monitoreo del consumo del límite de solicitudes
- Registro de solicitudes fallidas con contexto
- Configuración de comprobaciones de estado para integraciones críticas

## Common Integration Examples

### Stripe Payment Processing
```javascript
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

async function createPaymentIntent(amount, currency = 'usd') {
  return await stripe.paymentIntents.create({
    amount,
    currency,
    automatic_payment_methods: { enabled: true }
  });
}
```

### SendGrid Email Sending
```javascript
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

async function sendEmail(to, subject, html) {
  await sgMail.send({
    to,
    from: process.env.FROM_EMAIL,
    subject,
    html
  });
}
```

### Twilio SMS
```javascript
const twilio = require('twilio')(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

async function sendSMS(to, body) {
  await twilio.messages.create({
    to,
    from: process.env.TWILIO_PHONE_NUMBER,
    body
  });
}
```

## Troubleshooting

### Authentication Issues
- Verificar que las claves API estén configuradas correctamente
- Comprobar la caducidad del token
- Asegurarse de que los ámbitos de OAuth sean correctos
- Validar la generación de la firma

### Rate Limiting
- Implementar limitación de velocidad del lado del cliente
- Utilizar puntos de acceso para procesamiento por lotes cuando estén disponibles
- Distribuir las solicitudes a lo largo del tiempo
- Considerar la posibilidad de actualizar la capa de API

### Timeout Errors
- Aumentar los tiempos de espera para los puntos finales lentos
- Implementar la cancelación de solicitudes
- Utilizar la transmisión de datos para cargas útiles grandes
- Verificar la conectividad de red

Al integrar API, priorice la seguridad, la fiabilidad y la facilidad de mantenimiento. Pruebe siempre los escenarios de error y los casos límite antes de la implementación en producción.