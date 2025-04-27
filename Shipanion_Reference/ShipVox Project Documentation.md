
# ShipVox Project Documentation

## Project Overview
ShipVox is a shipping rate calculator application that integrates with FedEx's API to provide real-time shipping rates. The application uses a modern tech stack with a Flask backend and React/TypeScript frontend.

## Technical Stack

### Frontend
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Key Dependencies**:
  - react: ^18.3.1
  - react-dom: ^18.3.1
  - lucide-react: ^0.344.0

### Backend
- **Framework**: Flask (Python)
- **Key Components**:
  - FedExAuth: OAuth authentication manager
  - FedExRates: Rate calculation manager

## Architecture

### Backend Components

#### Main Application (`src/main.py`)
```python
# Core application setup
app = Flask(__name__)
auth_manager = FedExAuth()
rates_manager = FedExRates(auth_manager)
```

#### Key Endpoints

1. **Root Endpoint**
```python
@app.route('/')
def index():
    return render_template('index.html')
```
Serves the main application interface.

2. **Rate Calculator Endpoint**
```python
@app.route('/get-rates', methods=['POST'])
def get_rates():
```
- Accepts POST requests with shipping details
- Parameters:
  - originZip: Origin ZIP code
  - destinationZip: Destination ZIP code
  - weight: Package weight
  - dimensions: Package dimensions (length, width, height)
- Returns: JSON response with shipping rates or error message

### Frontend Components

#### App Component (`src/App.tsx`)
- Main application component
- Features:
  - Responsive navigation header
  - Company branding with ShipMind AI logo
  - Navigation links for Features and Benefits
  - Call-to-action button

#### UI Elements
- Custom styling using Tailwind CSS
- Gradient background
- Responsive design elements
- Shadow effects for depth
- Interactive hover states

## Data Flow

1. **User Input**
   - User enters shipping details in frontend form
   - Data is validated client-side

2. **API Request**
   - Frontend sends POST request to `/get-rates`
   - Request includes package and shipping details

3. **Backend Processing**
   - Flask backend validates input
   - Authenticates with FedEx using OAuth
   - Requests rates from FedEx API
   - Processes response

4. **Response Handling**
   - Backend returns JSON response
   - Frontend displays rates or error messages
   - User can view and compare shipping options

## Error Handling

### Backend
```python
try:
    # Process request
except ValueError:
    return jsonify({'error': 'Invalid numeric value provided'}), 400
except Exception:
    return jsonify({'error': str(e)}), 500
```
- Validates input data
- Handles numeric conversion errors
- Provides appropriate HTTP status codes
- Returns descriptive error messages

### Frontend
- Form validation
- Error state management
- User feedback display
- Loading states during API calls

## Configuration

### TypeScript Configuration
- Strict type checking enabled
- React JSX support
- Modern ES2020 features
- Module bundler integration

### Vite Configuration
```typescript
export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
});
```

### Tailwind Configuration
```javascript
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

## Security Considerations
- Environment variables for sensitive data
- Input validation on both ends
- OAuth implementation for API access
- Error message sanitization
- CORS configuration

## Development Workflow
1. Local development using `npm run dev`
2. TypeScript compilation and type checking
3. ESLint for code quality
4. Production build with `npm run build`
5. Flask server deployment

## Future Enhancements
- Additional shipping carriers
- Rate comparison features
- Address validation
- Shipping label generation
- User accounts and saved preferences

> Written with [StackEdit](https://stackedit.io/).