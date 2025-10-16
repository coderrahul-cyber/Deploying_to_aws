# Stage 1: Install Dependencies
ARG NODE=node:20-alpine 
FROM ${NODE} AS deps
#RUN apk add --no-cache libc6-compat: This command installs a compatibility library (libc6-compat) required by some Node.js native add-ons (like Next.js's SWC) to run correctly on Alpine Linux. The --no-cache flag ensures the package manager's index isn't stored, which helps keep the image layer small.
RUN apk add --no-cache libc6-compat 

WORKDIR /app

COPY package*.json ./
RUN npm install

# Stage 2: Build
FROM ${NODE} AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# Stage 3: Production Runner
FROM ${NODE} AS runner

WORKDIR /app

#ENV ...: These lines set environment variables for the container.
#NODE_ENV=production: Tells Next.js and other libraries to run in a highly optimized production mode.
#PORT=3000: Sets the port the application will listen on.
#NEXT_TELEMETRY_DISABLED=1: Disables Next.js's anonymous telemetry data collection.
ENV NODE_ENV production
ENV PORT 3000
ENV NEXT_TELEMETRY_DISABLED 1

# Install PM2 globally
RUN npm install -g pm2

# Create a non-root user
#RUN addgroup... & RUN adduser...: These two commands create a dedicated, non-root user (appuser) and group (nodegroup). Running the application as a non-root user is a critical security best practice that limits potential damage if a vulnerability is exploited.
RUN addgroup --system --gid 1001 nodegroup
RUN adduser --system --uid 1001 appuser

# Copy necessary files
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder --chown=appuser:nodegroup /app/.next/standalone ./
COPY --from=builder --chown=appuser:nodegroup /app/.next/static ./.next/static

#USER appuser: This switches the container's active user from root to our newly created appuser. Any commands that follow will be executed by this user.
USER appuser

EXPOSE 3000

# Start the application using PM2
CMD ["pm2-runtime", "node", "--", "server.js"]

